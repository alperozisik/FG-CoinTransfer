-- Extend the existing carried-currency view; never change character balances.
local rebuilding=false;

function onTabletopInit()
  if not Session.IsHost then return;end
  local original=PartyLootManager.buildPartyCoins;
  PartyLootManager.buildPartyCoins=function(...)
    original(...);
    mergePhysicalCoins();
  end
  for _,field in ipairs({"count","carried","name","cost","weight","cointransfer_currency"}) do
    DB.addHandler("charsheet.*.inventorylist.*." .. field,"onUpdate",refresh);
  end
  DB.addHandler("charsheet.*.coins.*.amount","onUpdate",refresh);
  DB.addHandler("charsheet.*.coins.*.name","onUpdate",refresh);
  DB.addHandler("partysheet.partyinformation.*.link","onUpdate",refresh);
  DB.addHandler("charsheet.*.name","onUpdate",refresh);
  for _,path in ipairs({"charsheet.*.inventorylist","charsheet.*.coins","partysheet.partyinformation"}) do
    DB.addHandler(path,"onChildAdded",refresh);
    DB.addHandler(path,"onChildDeleted",refresh);
  end
  CurrencyManager.registerCallback(refresh);
  refresh();
end

-- Use the native party-member and record-path APIs, including registered paths.
function collectTotals()
  local totals,affected,seen={},{},{};
  local currencies=CoinTransfer.currencyData();
  for _,actor in ipairs(PartyLootManager.getPartyMemberRecordsForCurrency()) do
    local path=DB.getPath(actor.node);
    if not seen[path] then
      seen[path]=true;
      local amounts={};
      local recordType=ActorManager.getRecordType(actor.node);
      for _,list in ipairs(ItemManager.getCurrencyPaths(recordType) or {}) do
        for _,coin in ipairs(DB.getChildList(actor.node,list)) do
          local name=DB.getValue(coin,"name","");
          name=CurrencyManager.getCurrencyMatch(name) or name:lower();
          local count=DB.getValue(coin,"amount",0);
          if name~="" and count>0 then amounts[name]=(amounts[name] or 0)+count;end
        end
      end
      for _,list in pairs(ItemManager.getInventoryPaths(recordType) or {}) do
        for _,item in ipairs(DB.getChildList(actor.node,list)) do
          local count=math.max(DB.getValue(item,"count",0),0);
          local carried=DB.getValue(item,"carried",0);
          if count>0 and (carried==1 or carried==2) then
            for _,currency in ipairs(currencies) do
              if CoinTransfer.itemCurrency(item,currency) then
                local name=CurrencyManager.getCurrencyMatch(currency.name) or currency.name:lower();
                affected[name]=true;
                amounts[name]=(amounts[name] or 0)+count;
                break;
              end
            end
          end
        end
      end
      for name,count in pairs(amounts) do
        totals[name]=totals[name] or {count=0,carriedby={}};
        totals[name].count=totals[name].count+count;
        table.insert(totals[name].carriedby,string.format("%s [%d]",actor.sName,math.floor(count)));
      end
    end
  end
  return totals,affected;
end

function mergePhysicalCoins()
  local totals,affected=collectTotals();
  local existing={};
  for _,row in ipairs(DB.getChildList("partysheet.coinlist")) do
    local name=DB.getValue(row,"name","");
    existing[CurrencyManager.getCurrencyMatch(name) or name:lower()]=row;
  end
  for name in pairs(affected) do
    local total=totals[name];
    local row=existing[name] or DB.createChild("partysheet.coinlist");
    DB.setValue(row,"name","string",name);
    DB.setValue(row,"amount","number",total.count);
    DB.setValue(row,"carriedby","string",table.concat(total.carriedby,", "));
  end
end

function refresh()
  if rebuilding then return;end
  rebuilding=true;
  local ok,err=pcall(PartyLootManager.buildPartyCoins);
  rebuilding=false;
  if not ok then Debug.console("Coin Transfer party totals",err);end
end
