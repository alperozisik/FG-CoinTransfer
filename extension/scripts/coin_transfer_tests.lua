-- Development harness. Excluded from the release archive.
local passed=0;
function onInit() Debug.console("CT test harness initialized");end
local function check(label,condition)
  if not condition then error("FAIL: " .. label);end
  passed=passed+1;Debug.console("CT PASS " .. label);
end
function onTabletopInit()
  Debug.console("CT harness enabled",Session.IsHost,DB.getValue("cointransfertest.enabled",0));
  if not Session.IsHost or DB.getValue("cointransfertest.enabled",0)~=1 then return;end
  local ok,err=pcall(run);
  DB.setValue("cointransfertest.result","string",ok and (tostring(passed) .. " checks passed") or tostring(err));
  Debug.console("CT TEST RESULT",passed,ok,tostring(err));
  local char=DB.findNode("charsheet.id-00001");
  local w=Interface.openWindow("charsheet",char);w.tabs.activateTabByName("inventory");CoinTransfer.open(char);
end
function run()
  OptionsManager.setOption("inventoryCoinsMNM","no");
  local char=DB.findNode("charsheet.id-00001");local other=DB.findNode("charsheet.id-00002");
  for _,path in ipairs({"inventorylist.name","inventorylist.count"}) do local n=DB.getChild(char,path);if n then DB.deleteNode(n);end end
  local currencies=CoinTransfer.currencyData();local gp,sp;
  for _,c in ipairs(currencies) do if c.name=="GP" then gp=c;elseif c.name=="SP" then sp=c;end end
  check("campaign currency metadata",gp and gp.value==1 and gp.weight==0.02);
  check("party member lookup",CoinTransfer.isPartyMember(char));
  for _,c in ipairs(currencies) do
    for _,node in ipairs(CoinTransfer.slots(CoinTransfer.endpoint(char,"coins"),c)) do DB.setValue(node,"amount","number",c.name=="GP" and 100 or c.name=="SP" and 20 or 0);end
    for _,node in ipairs(CoinTransfer.slots(CoinTransfer.endpoint(char,"party"),c)) do DB.setValue(node,"amount","number",c.name=="GP" and 300 or c.name=="SP" and 80 or 0);end
  end
  for _,ch in ipairs({char,other}) do for _,node in ipairs(DB.getChildList(ch,"inventorylist")) do if DB.getValue(node,"cointransfer_currency","")~="" then DB.deleteNode(node);end end end
  local coins=CoinTransfer.endpoint(char,"coins");local party=CoinTransfer.endpoint(char,"party");local bag=CoinTransfer.endpoint(char,"id-00001");local pack=CoinTransfer.endpoint(char,"id-00002");
  local function bal(ep,c) return CoinTransfer.balance(ep,c or gp);end
  local function total() return bal(coins)+bal(party)+bal(bag)+bal(pack)+bal(CoinTransfer.endpoint(char,"loose"));end
  local before=total();
  check("withdraw to Treasure",CoinTransfer.execute(char,"withdraw","coins",{[gp.id]=10}));
  check("Treasure and party deltas",bal(coins)==110 and bal(party)==290);
  check("withdraw to Bag of Holding",CoinTransfer.execute(char,"withdraw","id-00001",{[gp.id]=20}));
  check("physical item deltas",bal(bag)==20 and bal(party)==270 and bal(coins)==110);
  local item=CoinTransfer.slots(bag,gp)[1];local _,loc=DB.getValue(item,"locationshortcut","","");
  check("native container linkage",loc==DB.getPath(bag.container) and DB.getValue(item,"location","")=="Bag of Holding");
  check("unit weight and monetary cost",DB.getValue(item,"weight",0)==0.02 and DB.getValue(item,"cost","")=="1 GP");
  check("redeem physical items",CoinTransfer.execute(char,"redeem","id-00001",{[gp.id]=5}));
  check("redeem deltas",bal(bag)==15 and bal(coins)==115);
  check("materialize to backpack",CoinTransfer.execute(char,"materialize","id-00002",{[gp.id]=7,[sp.id]=4}));
  check("deposit physical coins",CoinTransfer.execute(char,"deposit","id-00002",{[gp.id]=2}));
  check("deposit Treasure coins",CoinTransfer.execute(char,"deposit","coins",{[gp.id]=3}));
  check("gold conservation",total()==before);
  check("remember destination",DB.getValue(char,"cointransfer.preferences.materialize","")=="id-00002");
  local snapshot=total();
  check("insufficient source rejected",not CoinTransfer.execute(char,"withdraw","coins",{[gp.id]=9999}));
  check("negative rejected",not CoinTransfer.execute(char,"withdraw","coins",{[gp.id]=-1}));
  check("fractional rejected",not CoinTransfer.execute(char,"withdraw","coins",{[gp.id]=1.5}));
  check("unknown currency rejected",not CoinTransfer.execute(char,"withdraw","coins",{["id-99999"]=1}));
  check("missing container rejected",not CoinTransfer.execute(char,"withdraw","id-99999",{[gp.id]=1}));
  check("all denominations prevalidated",not CoinTransfer.execute(char,"materialize","loose",{[gp.id]=1,[sp.id]=9999}));
  check("failed requests conserve balance",total()==snapshot);
  OptionsManager.setOption("inventoryCoinsMNM","yes");check("mirror rejects physical conversion",not CoinTransfer.execute(char,"materialize","loose",{[gp.id]=1}));OptionsManager.setOption("inventoryCoinsMNM","no");
  local duplicate=DB.createChild(DB.getChild(char,"inventorylist"));DB.setValue(duplicate,"name","string","Bag of Holding");DB.setValue(duplicate,"count","number",1);
  check("ambiguous container rejected",not CoinTransfer.execute(char,"withdraw","id-00001",{[gp.id]=1}));DB.deleteNode(duplicate);
  local definition=CoinTransfer.findDefinition(gp);local definitionPath=DB.getPath(definition);local count=DB.getChildCount("item");CoinTransfer.ensureDefinitions();
  check("existing templates reused",DB.getChildCount("item")==count and DB.getPath(CoinTransfer.findDefinition(gp))==definitionPath);
  local gemstone=DB.createChild(DB.getChild(char,"inventorylist"));DB.setValue(gemstone,"name","string","Polished Stone");DB.setValue(gemstone,"cost","string","1 GP");DB.setValue(gemstone,"weight","number",0.02);DB.setValue(gemstone,"count","number",1);
  check("ordinary valuable is not currency",not CoinTransfer.itemCurrency(gemstone,gp));DB.deleteNode(gemstone);
  local req="test" .. tostring(math.random(1000000000));local encoded=CoinTransfer.encodeRequest(req,"withdraw","coins",{[gp.id]=1});
  check("request parsing",CoinTransfer.decodeRequest(encoded).amounts[gp.id]==1);
  check("duplicate denominations rejected",not CoinTransfer.decodeRequest(req .. "|withdraw|coins|" .. gp.id .. "=1," .. gp.id .. "=2"));
  local old=bal(party);DB.setValue(char,"cointransfer.request","string",encoded);
  check("owned DB request processed on host",bal(party)==old-1);
  CoinTransfer.onRequest(DB.getChild(char,"cointransfer.request"));check("request replay rejected",bal(party)==old-1);
  local remaining=bal(party);
  check("first contender can claim pool",CoinTransfer.execute(char,"withdraw","coins",{[gp.id]=remaining}));
  check("second contender cannot overdraw",not CoinTransfer.execute(other,"withdraw","coins",{[gp.id]=1}));
  check("pool stayed at zero",bal(party)==0);
  check("return claimed pool",CoinTransfer.execute(char,"deposit","coins",{[gp.id]=remaining}));
  check("conservation after requests and contenders",total()==before);
  -- Regression: one displayed amount per character, across containers/states.
  local physical=CoinTransfer.slots(pack,gp)[1];
  local qty=DB.getValue(physical,"count",0);
  DB.setValue(physical,"carried","number",1);
  local totals=CoinTransferPartyTotals.collectTotals();local carriedTotal=totals.GP.count;
  DB.setValue(physical,"carried","number",0);
  totals=CoinTransferPartyTotals.collectTotals();
  check("Not Carried physical coins excluded",totals.GP.count==carriedTotal-qty);
  DB.setValue(physical,"carried","number",2);
  totals=CoinTransferPartyTotals.collectTotals();
  check("Equipped physical coins included",totals.GP.count==carriedTotal);
  DB.setValue(physical,"count","number",0);
  totals=CoinTransferPartyTotals.collectTotals();
  check("zero count physical coins excluded",totals.GP.count==carriedTotal-qty);
  DB.setValue(physical,"count","number",qty);DB.setValue(physical,"carried","number",1);
  CoinTransferPartyTotals.refresh();
  local row;
  for _,n in ipairs(DB.getChildList("partysheet.coinlist")) do if DB.getValue(n,"name","")=="GP" then row=n;end end
  check("party GP display includes physical coins",row and DB.getValue(row,"amount",0)==carriedTotal);
  local holders=DB.getValue(row,"carriedby","");local _,occurrences=holders:gsub("Coin Transfer Test 1 %[%d+%]","");
  check("one combined character entry",occurrences==1);
end
