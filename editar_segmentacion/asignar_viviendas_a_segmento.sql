/*
SELECT indec.asignar_viviendas_a_segmento('e0960', 'ARRAY [594, 595, 596]', 10006);
*/

drop indec.asignar_viviendas_a_segmento(esquema text, viviendas text, segmento_id bigint);
CREATE or replace FUNCTION indec.asignar_viviendas_a_segmento(esquema text, viviendas text, segmento_id bigint) 
RETURNS integer AS $$ 
declare cuantas integer;
begin
execute '
select count(*)
where listado_id = any (' || viviendas || ')
' into cuantas;

execute '
update ' || esquema || '.segmentacion 
set segmento_id = ''' || segmento_id || '''
where listado_id = any (' || viviendas || ')
';

return cuantas;
END $$ LANGUAGE plpgsql;
