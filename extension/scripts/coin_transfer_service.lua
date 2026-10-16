-- Coin Transfer. All shared-money writes run on the host.
-- A request is carried by an owned character DB leaf, never by a claimed username.
local busy = false;
local version = "0.1.3";
local partyList = "partysheet.treasureparcelcoinlist";
local maxCount = 1000000000;
local longNames = { CP="Copper Piece", SP="Silver Piece", EP="Electrum Piece", GP="Gold Piece", PP="Platinum Piece" };

function onInit()
  Comm.registerSlashHandler("cointransfer", openFromChat);
end

function onTabletopInit()
  ChatManager.SystemMessage("Coin Transfer v" .. version .. " loaded.");
  if Session.IsHost then
    DB.setPublic(DB.createNode(partyList), true);
    DB.createNode("cointransferledger");
    -- Stale requests are deliberately not executed after reconnect/reload.
    for _,n in ipairs(DB.getChildList("charsheet")) do
      DB.createChild(n, "cointransfer.request", "string");
      DB.createChild(n, "cointransfer.response", "string");
    end
    DB.addHandler("charsheet.*.cointransfer.request", "onUpdate", onRequest);
    ensureDefinitions();
  end
end

function currencyData()
  local out, seen = {}, {};
  for _,node in ipairs(DB.getChildList("currencies")) do
    local name = StringManager.trim(DB.getValue(node,"name",""));
    local weight, value = DB.getValue(node,"weight",0), DB.getValue(node,"value",0);
    if name ~= "" and weight >= 0 and value > 0 then
      if seen[name:lower()] then return {}, "Duplicate currency names must be resolved in Currencies."; end
      seen[name:lower()] = true;
      table.insert(out, {id=DB.getName(node),name=name,weight=weight,value=value});
    end
  end
  table.sort(out,function(a,b) if a.value~=b.value then return a.value>b.value; end return a.name<b.name; end);
  return out;
end

local function equal(a,b) return StringManager.trim(a):lower()==StringManager.trim(b):lower(); end
function coinName(c) return (longNames[c.name:upper()] or c.name .. " Coin") .. " (" .. c.name .. ")"; end

function itemCurrency(node,c)
  local tag = DB.getValue(node,"cointransfer_currency","");
  if tag ~= "" then return equal(tag,c.name); end
  -- Untagged records must have a denomination name, unit cost and unit weight.
  -- Generic valuables that happen to cost 1 GP must never be converted to coins.
  local name = DB.getValue(node,"name","");
  local recognized = equal(name,coinName(c)) or equal(name,c.name) or
    equal(name,c.name .. " Coins") or equal(name,c.name .. " Coin") or
    (longNames[c.name:upper()] and equal(name,longNames[c.name:upper()]));
  if not recognized then return false; end
  local amount, currency = CurrencyManager.parseCurrencyString(DB.getValue(node,ItemManager.getCostField(),""),true);
  return amount == 1 and currency and equal(currency,c.name) and
    math.abs(DB.getValue(node,"weight",0)-c.weight) < 0.000001;
end

function findDefinition(c)
  for _,node in ipairs(DB.getChildList("item")) do
    if itemCurrency(node,c) then return node; end
  end
  -- Loaded reference modules can already contain a usable currency item.
  for _,module in pairs(Module.getModules()) do
    local info = Module.getModuleInfo(module);
    if info and info.loaded then
      for _,path in ipairs({"item", "reference.items"}) do
        for _,node in ipairs(DB.getChildList(path .. "@" .. module)) do
          if itemCurrency(node,c) then return node; end
        end
      end
    end
  end
end

function ensureDefinitions()
  if not Session.IsHost then return; end
  for _,c in ipairs(currencyData()) do
    local node = findDefinition(c);
    if not node then
      node = DB.createChild("item");
      DB.setValue(node,"name","string",coinName(c));
      DB.setValue(node,"type","string","Treasure");
      DB.setValue(node,"subtype","string","Coins");
      DB.setValue(node,ItemManager.getCostField(),"string","1 " .. c.name);
      DB.setValue(node,"weight","number",c.weight);
      DB.setValue(node,"isidentified","number",1);
      DB.setValue(node,"locked","number",1);
      DB.setValue(node,"cointransfer_currency","string",c.name);
      DB.setValue(node,"description","formattedtext","<p>A single coin. Unit cost and weight follow the campaign currency definition.</p>");
      DB.setPublic(node,true);
    elseif DB.getValue(node,"cointransfer_currency","") ~= "" then
      -- Only our own definitions follow later currency configuration edits.
      DB.setValue(node,"weight","number",c.weight);
      DB.setValue(node,ItemManager.getCostField(),"string","1 " .. c.name);
      DB.setPublic(node,true);
    elseif not DB.getPath(node):find("@",1,true) then
      DB.setPublic(node,true);
    end
  end
end

function isPartyMember(char)
  for _,entry in ipairs(DB.getChildList("partysheet.partyinformation")) do
    local _,path=DB.getValue(entry,"link","","");
    if path==DB.getPath(char) then return true; end
  end
  return false;
end

function containers(char)
  local out = {};
  for _,node in ipairs(DB.getChildList(char,"inventorylist")) do
    local name=StringManager.trim(DB.getValue(node,"name",""));
    local lower=name:lower();
    local subtype=DB.getValue(node,"subtype",""):lower();
    if name~="" and (subtype:find("container",1,true) or DB.getValue(node,"capacity",0)>0 or DB.getValue(node,"capacityweight",0)>0 or
      lower:find("bag",1,true) or lower:find("backpack",1,true) or lower:find("pouch",1,true) or
      lower:find("sack",1,true) or lower:find("chest",1,true) or lower:find("portable hole",1,true)) then
      table.insert(out,{id=DB.getName(node),name=name,node=node});
    end
  end
  table.sort(out,function(a,b)return a.name:lower()<b.name:lower();end);
  return out;
end

function endpoint(char,id)
  if id=="party" then return {kind="party",path=partyList,name="Party Shared Coins"}; end
  if id=="coins" then return {kind="coins",path=DB.getPath(char,"coins"),name="Treasure > Coins"}; end
  if id=="loose" then return {kind="items",path=DB.getPath(char,"inventorylist"),name="Inventory (no container)",location=""}; end
  for _,c in ipairs(containers(char)) do
    if id==c.id then
      local matches=0;
      for _,other in ipairs(DB.getChildList(char,"inventorylist")) do
        if equal(DB.getValue(other,"name",""),c.name) then matches=matches+1; end
      end
      if matches~=1 then return nil,"Containers must have unique names."; end
      if DB.getValue(c.node,"count",0)~=1 then return nil,"Choose a container with quantity 1."; end
      return {kind="items",path=DB.getPath(char,"inventorylist"),name=c.name,location=c.name,container=c.node};
    end
  end
  return nil,"The selected container no longer exists. Select another destination.";
end

local function located(node,ep)
  local _,link=DB.getValue(node,"locationshortcut","","");
  if ep.container and link~="" then return link==DB.getPath(ep.container); end
  if not ep.container and link~="" then return false; end
  return equal(DB.getValue(node,"location",""),ep.location or "");
end

function slots(ep,c)
  local out={};
  for _,node in ipairs(DB.getChildList(ep.path)) do
    local matches;
    if ep.kind=="items" then matches=itemCurrency(node,c) and located(node,ep);
    else matches=equal(DB.getValue(node,ep.kind=="party" and "description" or "name",""),c.name); end
    if matches then table.insert(out,node); end
  end
  table.sort(out,function(a,b)return DB.getPath(a)<DB.getPath(b);end);
  return out;
end

function balance(ep,c)
  local total=0;
  for _,node in ipairs(slots(ep,c)) do
    local n=DB.getValue(node,ep.kind=="items" and "count" or "amount",0);
    if n<0 or n~=math.floor(n) or n>maxCount then return nil; end
    total=total+n;
  end
  return total;
end

function mirrorEnabled()
  return OptionsManager.isOption("inventoryCoinsMNM","yes");
end

function validate(char,mode,selection,amounts)
  if not char or not DB.getPath(char):match("^charsheet%.id%-%d+$") then return nil,"Invalid character."; end
  if (mode=="withdraw" or mode=="deposit") and not isPartyMember(char) then return nil,"This character must be on the Party Sheet."; end
  local selected,err=endpoint(char,selection);
  if not selected or selected.kind=="party" then return nil,err or "Choose a character destination."; end
  local source,target;
  if mode=="withdraw" then source=endpoint(char,"party");target=selected;
  elseif mode=="deposit" then source=selected;target=endpoint(char,"party");
  elseif mode=="materialize" and selected.kind=="items" then source=endpoint(char,"coins");target=selected;
  elseif mode=="redeem" and selected.kind=="items" then source=selected;target=endpoint(char,"coins");
  else return nil,"Invalid operation or inventory selection."; end
  if mirrorEnabled() and (source.kind=="items" or target.kind=="items") then
    return nil,"MNM inventory coin mirroring is enabled. The GM must disable that option before physical coin transfers.";
  end
  local currencies,currencyError=currencyData();
  if currencyError then return nil,currencyError; end
  local known,total,rows={},0,{};
  for _,c in ipairs(currencies) do
    known[c.id]=true;
    local n=amounts[c.id] or 0;
    if type(n)~="number" or n~=n or n<0 or n~=math.floor(n) or n>maxCount then return nil,"Enter whole, non-negative coin quantities."; end
    if n>0 then
      local available=balance(source,c);
      if not available then return nil,"The source has an invalid coin quantity."; end
      if available<n then return nil,"Not enough " .. c.name .. " in " .. source.name .. "."; end
      local destinationBalance=balance(target,c);
      if not destinationBalance or destinationBalance+n>maxCount then return nil,"Destination coin quantity exceeds the supported limit."; end
      table.insert(rows,{c=c,n=n});total=total+n;
    end
  end
  for id in pairs(amounts) do if not known[id] then return nil,"Unknown currency. Refresh and try again."; end end
  if total==0 then return nil,"Enter at least one coin quantity."; end
  return {source=source,target=target,rows=rows,mode=mode,selection=selection};
end

local function setNumber(node,field,n,undo)
  local old=DB.getValue(node,field,0);
  table.insert(undo,function() DB.setValue(node,field,"number",old); end);
  DB.setValue(node,field,"number",n);
end

function execute(char,mode,selection,amounts)
  if not Session.IsHost then return false,"Transfers are processed by the host."; end
  if busy then return false,"Another transfer is being processed. Try again."; end
  local plan,err=validate(char,mode,selection,amounts);
  if not plan then return false,err; end
  busy=true;
  local undo={};
  local ok,failure=pcall(function()
    for _,row in ipairs(plan.rows) do
      local remaining=row.n;
      local sourceField=plan.source.kind=="items" and "count" or "amount";
      for _,node in ipairs(slots(plan.source,row.c)) do
        local existing=DB.getValue(node,sourceField,0);
        local take=math.min(existing,remaining);
        if take>0 then setNumber(node,sourceField,existing-take,undo);remaining=remaining-take; end
      end
      local destinations=slots(plan.target,row.c);
      local target=destinations[1];
      if not target then
        target=DB.createChild(plan.target.path);
        if not target then error("Unable to create destination record"); end
        local created=target;table.insert(undo,function() DB.deleteNode(created); end);
        if plan.target.kind=="items" then
          local definition=findDefinition(row.c);
          if not definition then ensureDefinitions();definition=findDefinition(row.c); end
          if not definition then error("No currency item definition"); end
          DB.copyNode(definition,target);
          DB.setValue(target,"count","number",0);
          DB.setValue(target,"location","string",plan.target.location or "");
          if plan.target.container then
            DB.setValue(target,"locationshortcut","windowreference","item",DB.getPath(plan.target.container));
          end
          DB.setValue(target,"carried","number",plan.target.container and DB.getValue(plan.target.container,"carried",1) or 1);
          DB.setValue(target,"isidentified","number",1);
          DB.setValue(target,"cointransfer_currency","string",row.c.name);
        else
          DB.setValue(target,plan.target.kind=="party" and "description" or "name","string",row.c.name);
          if plan.target.kind=="party" then DB.setPublic(target,true); end
        end
      end
      local field=plan.target.kind=="items" and "count" or "amount";
      setNumber(target,field,DB.getValue(target,field,0)+row.n,undo);
    end
  end);
  if not ok then
    for i=#undo,1,-1 do pcall(undo[i]); end
    busy=false;Debug.console("Coin Transfer rollback",tostring(failure));
    return false,"Transfer failed; balances were restored. See the host console.";
  end
  busy=false;
  local details={};
  for _,row in ipairs(plan.rows) do table.insert(details,tostring(row.n) .. " " .. row.c.name); end
  local message=table.concat(details,", ") .. ": " .. plan.source.name .. " -> " .. plan.target.name;
  local entry=DB.createChild("cointransferledger.transactions");
  DB.setValue(entry,"character","string",DB.getPath(char));
  DB.setValue(entry,"name","string",DB.getValue(char,"name",""));
  DB.setValue(entry,"summary","string",message);
  DB.setValue(char,"cointransfer.preferences." .. mode,"string",selection);
  ChatManager.SystemMessage("Coin Transfer | " .. DB.getValue(char,"name","Character") .. " | " .. message);
  return true,message;
end

function encodeRequest(nonce,mode,selection,amounts)
  local rows={};
  for id,n in pairs(amounts) do table.insert(rows,id .. "=" .. tostring(n)); end
  table.sort(rows);
  return nonce .. "|" .. mode .. "|" .. selection .. "|" .. table.concat(rows,",");
end

function decodeRequest(text)
  if #text>4096 then return nil; end
  local nonce,mode,selection,rows=text:match("^([%w%-]+)|(%a+)|([%w%-]+)|(.*)$");
  if not nonce or #nonce>80 then return nil; end
  local amounts={};
  for pair in (rows .. ","):gmatch("(.-),") do
    local id,n=pair:match("^(id%-%d+)=([%d%.%-]+)$");
    if not id or amounts[id]~=nil or not tonumber(n) then return nil; end
    amounts[id]=tonumber(n);
  end
  return {nonce=nonce,mode=mode,selection=selection,amounts=amounts};
end

function onRequest(node)
  local char=DB.getChild(node,"...");
  local req=decodeRequest(DB.getValue(DB.getParent(node),"request",""));
  if not char or not req then return; end
  local state=DB.createNode("cointransferledger.requests." .. DB.getName(char));
  -- Replay IDs persist in the host-only ledger. No client-provided identity is trusted.
  if DB.getChild(state,req.nonce) then
    DB.setValue(char,"cointransfer.response","string",req.nonce .. "|error|This request has already been processed.");return;
  end
  DB.setValue(state,req.nonce,"number",1);
  local ok,message=execute(char,req.mode,req.selection,req.amounts);
  DB.setValue(char,"cointransfer.response","string",req.nonce .. "|" .. (ok and "ok" or "error") .. "|" .. message);
end

function submit(char,mode,selection,amounts)
  if Session.IsHost then return execute(char,mode,selection,amounts); end
  local nonce="r" .. tostring(math.random(1000000000)) .. "x" .. tostring(math.random(1000000000));
  DB.setValue(char,"cointransfer.request","string",encodeRequest(nonce,mode,selection,amounts));
  return nil,nonce;
end

function open(char)
  if char then Interface.openWindow("cointransfer_window",char); end
end
function openFromChat(_,text)
  local active=User.getCurrentIdentity();
  local char=active and DB.findNode("charsheet." .. active);
  if not char and Session.IsHost and text and text~="" then
    for _,n in ipairs(DB.getChildList("charsheet")) do if equal(DB.getValue(n,"name",""),text) then char=n;break;end end
  end
  if char then open(char); else ChatManager.SystemMessage("Use the character's Coin Transfer button, or /cointransfer with an active character. The GM can use /cointransfer <character name>."); end
end
