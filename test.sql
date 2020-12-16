create index listado_idx on e0002.listado (id);
create index listado_pdcfrml on e0002.listado (prov, dpto, codloc, frac, radio, mza, lado);
create index listado_piso on e0002.listado (prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso);


with
parametros as (select 36::float as deseado),
listado as (select * from e0002.listado),
listado_sin_nulos as (
    select id, prov, dpto, codloc, frac, radio, mza, lado, nrocatastr,
    coalesce(sector,'') sector, coalesce(edificio,'') edificio, coalesce(entrada,'') entrada,
    piso, coalesce(CASE WHEN orden_reco='' THEN NULL ELSE orden_reco END,'0')::integer orden_reco
    from listado
    ),
casos as (
    select prov, dpto, codloc, frac, radio, mza,
           count(*) as vivs, ceil(count(*)/deseado) as max, greatest(1, floor(count(*)/deseado)) as min
    from listado_sin_nulos, parametros
    group by prov, dpto, codloc, frac, radio, mza, deseado
    order by prov, dpto, codloc, frac, radio, mza, deseado
    ),
deseado_manzana as (
    select prov, dpto, codloc, frac, radio, mza, vivs,
        case when abs(vivs/max - deseado) < abs(vivs/min - deseado) then max else min end as segs_x_mza
    from casos, parametros
    ),
pisos_abiertos as (
    select id, prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso, orden_reco::integer,
        row_number() over w as row, rank() over w as rank
    from listado_sin_nulos
    window w as (
        partition by prov, dpto, codloc, frac, radio, mza
        order by lado::integer, orden_reco::integer)
    ),
asignacion_segmentos as (
    select id, prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso, orden_reco::integer,
        floor((rank - 1)*segs_x_mza/vivs) + 1 as sgm_mza, rank
    from deseado_manzana
    join pisos_abiertos
    using (prov, dpto, codloc, frac, radio, mza)
    ),
asignacion_segmentos_pisos_enteros as (
    select prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso, min(sgm_mza) as sgm_mza
    from asignacion_segmentos
    group by prov, dpto, codloc, frac, radio, mza, lado,
        nrocatastr, sector, edificio, entrada, piso
    )
select id, prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso, orden_reco::integer,
    sgm_mza
from listado_sin_nulos
join asignacion_segmentos_pisos_enteros
using (prov, dpto, codloc, frac, radio, mza, lado, nrocatastr, sector, edificio, entrada, piso)
;


