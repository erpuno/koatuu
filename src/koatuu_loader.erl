-module (koatuu_loader).
-include("koatuu.hrl").
-include("dict.hrl").
-include_lib("kvs/include/cursors.hrl").
-export ([boot/0]).

boot() ->
  case kvs:get(writer, <<"/L1/М.СЕВАСТОПОЛЬ"/utf8>>) of
    {ok,_} -> skip;
    {error,_} ->
       append_locality_types(),
       l1(append),
       koatuu:warning("Import koatuu was done.", [])
  end.

l1(append)->
    [{Key2, Code2, Name2, Type2, MainCity2},
     {Key1, Code1, Name1, Type1, MainCity1}|T] = lists:reverse(l1()),
    appendL1(Key1, Code1, Name1, Type1, MainCity1, ?REGIONS, <<"0000000001">>),
    appendL1(Key2, Code2, Name2, Type2, MainCity2, ?REGIONS, <<"0000000002">>),
    lists:map(
        fun({Key, Code, Name, Type, MainCity}) ->
            appendL1(Key, Code, Name, Type, MainCity, ?REGIONS)
        end, lists:reverse(T)).

l1()->
  koatuu:warning("Start import koatuu. Please, wait...", []),
  lists:flatten(
    lists:map(
      fun(H) ->
        {TypeL1, NameL1, MainCity} = filterL1(name(H), code(H)),
        KeyL1 = keyL1(NameL1),
        koatuu:debug("-- Import: ~ts", [KeyL1]),
        Data = l2(dataLevel2(H), []),
        Sorted = lists:keysort(2, Data),
        append(Sorted, KeyL1),
        {KeyL1, code(H), NameL1, TypeL1, MainCity}
      end, dataLevel1(allData()))).

l2([], Districts)-> lists:flatten(Districts);
l2([H|T], Districts)->
  case bitGet(1, 2, code(H)) of
     <<"1">> ->
        case dataLevel3(H) of
           [] -> l2(T, [{code(H), name(H), region_city, [], [], []}|Districts]);
           DataLevel3 ->
              RegionCity = region_city(DataLevel3, name(H)),
              l2(T, [{code(H), name(H), region_city, [], [], []}, RegionCity|Districts])
        end;
    <<"2">> ->
        case checkCode(3, code(H)) of
           true -> l2(T, Districts);
           false ->
             [DistrictName, MainCity] = string:split(name(H), <<"/">>),
             District = district(dataLevel3(H), MainCity, DistrictName),
             l2(T, [District|Districts])
        end;
    <<"3">> ->
        District = district(dataLevel3(H), [], name(H)),
        l2(T, [{code(H), name(H), city_district, [], [], []}, District|Districts])
  end.

region_city(DataLevel3, MainCity)->
  lists:flatten(
    lists:map(
       fun(H) ->
         case {dataLevel4(H), ?TYPE_1(type(H))} of
            {_, error} -> [];
            {[], village_council} -> [];
            {DataLevel4, village_council} -> towns(DataLevel4, MainCity, [], name(H));
            {[], TypeL3} -> {code(H), name(H), TypeL3, MainCity, [], []};
            {DataLevel4, TypeL3} ->
                [{code(H), name(H), TypeL3, MainCity, name(H), []},
                towns(DataLevel4, MainCity, name(H), [])]
          end
       end, DataLevel3)).

district(undefined, _MainCity, _DistrictName)->[];
district(DataLevel3, MainCity, DistrictName)->
  lists:flatten(
    lists:map(
      fun(H) ->
         case {dataLevel4(H), ?TYPE_2(type(H))} of
            {_, error} -> [];
            {[], village_council} -> [];
            {DataLevel4, village_council} -> towns(DataLevel4, MainCity, DistrictName, name(H));
            {[], TypeL3} -> {code(H), name(H), TypeL3, MainCity, DistrictName, []};
            {DataLevel4, TypeL3} -> [{code(H), name(H), TypeL3, MainCity, DistrictName, []},
                                      towns(DataLevel4, MainCity, DistrictName, [])]
         end
      end, DataLevel3)).

towns(DataLevel4, MainCity, DistrictName, VillageCouncil)->
  lists:flatten(
    lists:map(
       fun (H)->
          case ?TYPE_2(type(H)) of
             error -> [];
             village_council -> [];
              TypeL3->{code(H), name(H), TypeL3, MainCity, DistrictName, VillageCouncil}
          end
       end, DataLevel4)).

allData()->
  FilePath = code:priv_dir(koatuu)++"/koatuu/koatuu.json",
  {ok, Bin} = file:read_file(FilePath),
  jsone:decode(Bin).

checkCode(Bit, Code)-> <<_N:Bit/binary, M/binary>> = Code, list_to_integer(binary_to_list(M)) == 0.
bitGet(CountBit, Skip, Code)-> <<_N:Skip/binary, M:CountBit/binary, _O/binary>> = Code, M.

dataLevel1(Data)->maps:get(<<"level1">>, Data, []).
dataLevel2(Data)->[_A|Level2] = maps:get(<<"level2">>, Data, []), Level2.
dataLevel3(Data)->maps:get(<<"level3">>, Data, []).
dataLevel4(Data)->maps:get(<<"level4">>, Data, []).

name(H)->maps:get(<<"name">>, H, []).
type(H)->maps:get(<<"type">>, H, []).
code(H)->maps:get(<<"code">>, H, []).

kDistr(D)-> <<D/binary, " РАЙОН"/utf8>>.
kCity(C)-> <<"М."/utf8, C/binary>>.
kTown(T)-> <<"СМТ "/utf8, T/binary>>.
key([], L2)-> L2;
key(L1, L2)-> <<L1/binary, "/", L2/binary>>.
keyL1(Level1)-> <<"/L1/", Level1/binary>>.

appendL1(Id, KoatuuId, Name, Type, MainCity, Feed, Pos) ->
  kvs:append(#locality{id = Pos, koatuu_id = KoatuuId, name = Name,
    type = erlang:atom_to_list(Type), l1_id = Id, main_city = MainCity}, Feed).

appendL1(Id, KoatuuId, Name, Type, MainCity, Feed) ->
  kvs:append(#locality{id = KoatuuId, koatuu_id = KoatuuId, name = Name,
    type = erlang:atom_to_list(Type), l1_id = Id, main_city = MainCity}, Feed).

append_locality_types()->
  lists:map(
    fun ({Id, Description}) ->
      kvs:append(#dict{id = erlang:atom_to_list(Id), type = locality_type,
          name = Description}, ?FEED_LOCALITY_TYPES)
    end, ?LOCALITY_TYPES).

filterL1(Name, KoatuuId)->
  case {KoatuuId,  string:split(Name, <<"/">>) } of
    {<<"8000000000">>, _} -> {capital, Name, []};
    {<<"8500000000">>, _} -> {special_city, Name, []};
    {_, [NameL1, MainCity]} -> {region, NameL1, MainCity}
  end.

append([], _) -> ok;
append({Code, Name, Type, MainCity, DistrictName, VillageCouncil}, Feed) ->
  L2Id = case Type of
    region_city -> kCity(Name);
    city_district -> kDistr(Name);
    region_city_district -> kDistr(Name);
    city -> KCity = kCity(Name), key(DistrictName, KCity);
    town -> kTown(Name);
    _ -> key(DistrictName, Name)
 end,
 Record =
   #locality{id = <<(koatuu_abc:id(Name))/binary,Code/binary>>,
      koatuu_id = Code,
      name = Name,
      type = erlang:atom_to_list(Type),
      l1_id = Feed,
      l2_id = L2Id,
      district = DistrictName,
      main_city = MainCity,
      village_council = VillageCouncil},
   kvs:append(Record, Feed);

append([H|T], Feed) ->
   append(H, Feed),
   append(T, Feed).
