local ready=false;
local pending=nil;
local selectedMode="withdraw";
local watched={};
function onInit()
  title.setValue("Coin Transfer - " .. DB.getValue(getDatabaseNode(),"name","Character"));
  for _,v in ipairs({{"withdraw","Withdraw from Party"},{"deposit","Deposit to Party"},{"materialize","Coins -> Items"},{"redeem","Items -> Coins"}}) do operation.add(v[1],v[2]);end
  operation.setValue(DB.getValue(getDatabaseNode(),"cointransfer.preferences.mode","withdraw"));
  ready=true;modeChanged();
  local p=DB.getPath(getDatabaseNode());
  for _,s in ipairs({p..".coins.*.amount",p..".inventorylist.*.count",p..".inventorylist.*.location",p..".inventorylist.*.locationshortcut","partysheet.treasureparcelcoinlist.*.amount","partysheet.partyinformation.*.link"}) do
    DB.addHandler(s,"onUpdate",refreshBalances);table.insert(watched,{s,"onUpdate",refreshBalances});
  end
  for _,s in ipairs({p..".coins",p..".inventorylist","partysheet.treasureparcelcoinlist","partysheet.partyinformation"}) do
    for _,event in ipairs({"onChildAdded","onChildDeleted"}) do DB.addHandler(s,event,refreshBalances);table.insert(watched,{s,event,refreshBalances});end
  end
  DB.addHandler(p..".cointransfer.response","onUpdate",onResponse);table.insert(watched,{p..".cointransfer.response","onUpdate",onResponse});
  OptionsManager.registerCallback("inventoryCoinsMNM",refreshBalances);CurrencyManager.registerCallback(rebuild);
end
function onClose()
  ready=false;
  for _,h in ipairs(watched) do DB.removeHandler(h[1],h[2],h[3]);end
  OptionsManager.unregisterCallback("inventoryCoinsMNM",refreshBalances);CurrencyManager.unregisterCallback(rebuild);
end
function modeChanged()
  if not ready then return;end
  selectedMode=operation.getValue();
  DB.setValue(getDatabaseNode(),"cointransfer.preferences.mode","string",selectedMode);
  if selectedMode=="deposit" or selectedMode=="redeem" then selection_label.setValue("Source");else selection_label.setValue("Destination");end
  rebuild();
end
function rebuild()
  if not ready then return;end
  ready=false;
  local previous=DB.getValue(getDatabaseNode(),"cointransfer.preferences." .. selectedMode,"");
  local old={};for _,v in ipairs(selection.getValuesData()) do table.insert(old,v);end
  for _,v in ipairs(old) do selection.remove(v);end
  if selectedMode=="withdraw" or selectedMode=="deposit" then selection.add("coins","Treasure > Coins");end
  selection.add("loose","Inventory (no container)");
  local found=previous=="loose" or (previous=="coins" and (selectedMode=="withdraw" or selectedMode=="deposit"));
  for _,c in ipairs(CoinTransfer.containers(getDatabaseNode())) do selection.add(c.id,c.name);if previous==c.id then found=true;end end
  if previous~="" and not found then selection.add(previous,"Missing container - choose another");end
  selection.setValue(previous~="" and previous or ((selectedMode=="withdraw" or selectedMode=="deposit") and "coins" or "loose"));
  quantities.closeAll();
  for _,c in ipairs(CoinTransfer.currencyData()) do local w=quantities.createWindow();w.currency=c;w.denomination.setValue(c.name);w.quantity.setValue(0);end
  ready=true;status.setValue("Choose quantities, then click Transfer. Coins keep their denomination.");refreshBalances();
end
function selectionChanged()
  if ready then DB.setValue(getDatabaseNode(),"cointransfer.preferences." .. selectedMode,"string",selection.getValue());refreshBalances();end
end
function amounts()
  local out={};for _,w in ipairs(quantities.getWindows()) do if w.currency then out[w.currency.id]=w.quantity.getValue();end end;return out;
end
function refreshBalances()
  if not ready then return;end
  local selected=CoinTransfer.endpoint(getDatabaseNode(),selection.getValue());
  local source,target;
  if selectedMode=="withdraw" then source=CoinTransfer.endpoint(getDatabaseNode(),"party");target=selected;
  elseif selectedMode=="deposit" then source=selected;target=CoinTransfer.endpoint(getDatabaseNode(),"party");
  elseif selectedMode=="materialize" then source=CoinTransfer.endpoint(getDatabaseNode(),"coins");target=selected;
  else source=selected;target=CoinTransfer.endpoint(getDatabaseNode(),"coins");end
  local nValue,nWeight=0,0;
  for _,w in ipairs(quantities.getWindows()) do
    if w.currency then
      w.available.setValue(source and CoinTransfer.balance(source,w.currency) or 0);
      w.after.setValue((target and CoinTransfer.balance(target,w.currency) or 0)+w.quantity.getValue());
      nValue=nValue+w.quantity.getValue()*w.currency.value;nWeight=nWeight+w.quantity.getValue()*w.currency.weight;
    end
  end
  local primary=CurrencyManager.getDefaultCurrency();if primary=="" then primary=GameSystem.currencyDefault or "GP";end local divisor=CurrencyManager.getCurrencyValue(primary);if divisor>0 then nValue=nValue/divisor;end
  summary.setValue(string.format("Selected: %.2f %s   |   Coin weight: %.2f lb",nValue,primary,nWeight));
  local plan,err=CoinTransfer.validate(getDatabaseNode(),selectedMode,selection.getValue(),amounts());
  apply.setEnabled(plan~=nil and pending==nil);
  hint.setValue(pending and "Waiting for the host..." or (plan and source.name .. " -> " .. target.name or err));
end
function fillAll() for _,w in ipairs(quantities.getWindows()) do w.quantity.setValue(w.available.getValue());end refreshBalances();end
function resetQuantities() for _,w in ipairs(quantities.getWindows()) do w.quantity.setValue(0);end refreshBalances();end
function transfer()
  if pending then return;end
  local ok,message=CoinTransfer.submit(getDatabaseNode(),selectedMode,selection.getValue(),amounts());
  if ok==nil then pending=message;status.setValue("Request sent. Waiting for the host.");
  elseif ok then resetQuantities();status.setValue("Transferred: " .. message);else status.setValue(message);end
  refreshBalances();
end
function onResponse()
  local nonce,result,message=DB.getValue(getDatabaseNode(),"cointransfer.response",""):match("^([^|]+)|([^|]+)|(.*)$");
  if nonce~=pending then return;end
  pending=nil;if result=="ok" then resetQuantities();status.setValue("Transferred: " .. message);else status.setValue(message);end refreshBalances();
end
