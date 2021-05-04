/*
titulo: excluye_colectivas.sql
descripción:
devuelve el text para excluir las viviendas colectivas el segmento_lado
autor: -h
fecha: 2021-04-26

*/

DROP FUNCTION if exists indec.excluye_colectivas_s(text, _seg_id integer);
create or replace function indec.excluye_colectivas_s(esquema text, _seg_id integer)
 returns text
 language plpgsql volatile
set client_min_messages = error
as $function$

declare 
a_excluir text;
cuantos integer;

begin
 
execute '
with
  listado as (select * 
    from "' || esquema || '".listado 
    where tipoviv = ''CO''
  ),
  segmentacion as (select * from "' || esquema || '".segmentacion where segmento_id = ' || _seg_id || '),
  casos as (select * from listado join segmentacion on listado.id = listado_id)

select string_agg(indec.descripcion_domicilio(''' || esquema || ''', id), '', '')::text as descripcion, count(*) 
from casos
;' into a_excluir, cuantos;

if cuantos > 1 then 
  a_excluir = '.  Se excluyen las viviendas colectivas sitas en: ' || a_excluir;
elseif cuantos = 1 then
  a_excluir = '.  Se excluye la vivienda colectiva sita en: ' || a_excluir;
else
  a_excluir = '';
end if;

return a_excluir;

end;
$function$
;


