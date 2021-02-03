/* Dynamis Data */

select well as WELL, test_date as TEST_DATE, duration as DURATION, round(gross_oil_rate,2) as GROSS, round(net_oil_rate,2) as OIL, round(water_cut,2) as WC, 
round(gas_rate,2) as GAS, round(tubing_pressure,2) as TUBING_PRESSURE, round(tubing_temperature,2) as TUBING_TEMPERATURE, round(casing_pressure,2) as CASING_PRESSURE
from datamart.well_test
where well = 'L5A-286ST' and test_date between '01-01-2019' and '31-12-2019'
order by well asc, test_date asc;

select well, test_date, psd, dfl, sfl, subm from datamart.sonolog
where structure = 'Tanjung (WF/SecRec)' and test_date between '01-01-2019' and '31-12-2019'
order by well asc, test_date asc;

select well, test_date, winj, waterthp as WHP from datamart.winj_test
where well = 'L5A-237' and test_date between '01-01-2019' and '31-12-2019'
order by well asc, test_date asc;

select well, off_date, on_date, round(extract(day from (on_date - off_date))*24 + extract(hour from (on_date - off_date)) + extract(minute from (on_date - off_date))/60 +
extract(second from (on_date - off_date))/3600,2) as off_duration, reason from datamart.well_off
where structure = 'Tanjung (WF/SecRec)'
order by off_date desc;

select well, test_date, spm, sl, pump_displacement from datamart.well_dynagraph
where well = 'KWG-098' and test_date between '01-01-2019' and '31-12-2020'
order by well asc, test_date asc;

/* Statis Data */

select well, md, tvd, azim, incl, dx, dy from datamart.well_directional_survey
where well = 'T-164'
order by md asc;

select * from (select well, installdate, pulldate, liftingmethod as LIFTING_METHOD, type, pumpdepth as PSN, eos from datamart.well_lifting_data
where well = 'T-164'
order by installdate desc)
where rownum  <= 1;

select well, status_date, top_perf as TOP, bot_perf as BOTTOM, status, perforate_date, spf from datamart.perforation_status
where well = 'T-164'
order by status_date asc;

select well, layer, topmd as TOP, botmd as BOTTOM, net_thick as NET_THICKNESS, perm as PERMEABILITY, poro as POSOSITY, sw, version, versiondate as VERSION_DATE
from datamart.well_properties
where well = 'T-164'
order by topmd asc;

select well as well_join ,max(off_date) as max_off_date from datamart.well_off
where structure = 'Tanjung (WF/SecRec)'
group by well
order by max(off_date) desc;

/* Final Daily Report Datamart */

/* Well Off */

select well, off_date, on_date, to_date(to_char(cast(off_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') as date_off, to_date(to_char(cast(on_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') as date_on,
to_date(to_char(cast(on_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') - to_date(to_char(cast(off_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') - 1 as OFF_DAYS_BETWEEN,
reason from datamart.well_off
inner join (select well as well_join ,max(off_date) as max_off_date from datamart.well_off
where structure = 'Bentayan'
group by well
order by max(off_date) desc)
on well = well_join and off_date = max_off_date
where structure = 'Bentayan'
order by off_date desc;

select well, date_off as LAST_OFF_DATE, date_on as LAST_ON_DATE, OFF_DAYS_BETWEEN,
    case
        when OFF_DAYS_BETWEEN = -1 Then round(extract(day from (on_date - off_date))*24 + extract(hour from (on_date - off_date)) + 
                                extract(minute from (on_date - off_date))/60 + extract(second from (on_date - off_date))/3600,2)
        else 24.00 - round(extract(hour from(off_date)) + extract(minute from off_date)/60 + extract(second from off_date)/3600,2)
    end as off_duration_at_offdate,
    case
        when OFF_DAYS_BETWEEN = -1 Then 0
        when OFF_DAYS_BETWEEN > -1 and date_on = to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') Then 24
        else round(extract(hour from(on_date)) + extract(minute from on_date)/60 + extract(second from on_date)/3600,2) 
    end as off_duration_at_ondate,
reason from (select well, off_date, on_date, to_date(to_char(cast(off_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') as date_off, nvl(to_date(to_char(cast(on_date as date),'DD-MM-YYYY'),'DD-MM-YYYY'),to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY')) as date_on,
nvl(to_date(to_char(cast(on_date as date),'DD-MM-YYYY'),'DD-MM-YYYY'),to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY')) - to_date(to_char(cast(off_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') - 1 as OFF_DAYS_BETWEEN,
reason from datamart.well_off
inner join (select well as well_join ,max(off_date) as max_off_date from datamart.well_off
where structure = 'Bentayan'
group by well
order by max(off_date) desc)
on well = well_join and off_date = max_off_date
where structure = 'Bentayan'
order by off_date desc);

/* Well Test */

select well, test_date, gross_oil_rate as GROSS, net_oil_rate as OIL, water_cut as WC, gas_rate as GAS, tubing_pressure, tubing_temperature, casing_pressure from datamart.well_test
inner join (select well as well_join, max(test_date) as max_test_date from datamart.well_test
where structure = 'Bentayan'
group by well
order by max_test_date desc)
on well = well_join and test_date = max_test_date
where structure = 'Bentayan'
order by test_date desc;

/* Sonolog */

select well, test_date, psd, dfl, sfl, subm from datamart.sonolog
inner join (select well as well_join, max(test_date) as max_test_date from datamart.sonolog
where structure = 'Bentayan'
group by well
order by max_test_date desc)
on well = well_join and test_date = max_test_date
where structure = 'Bentayan'
order by test_date desc;

/* Lifting Data */

select well, liftingmethod as LIFTING_METHOD, type from datamart.well_lifting_data
inner join (select well as well_join,max(installdate) as max_installdate from datamart.well_lifting_data
where structure = 'Bentayan' and pulldate is null
group by well
order by max_installdate desc)
on well = well_join and installdate = max_installdate
where structure = 'Bentayan'
order by installdate desc;

/* Well Job */

select well, jenis_kegiatan, rig_name, start_date, end_date, kategori_kegiatan from datamart.well_job_metric
inner join (select well as well_join, max(start_date) as max_start_date from datamart.well_job_metric
where structure = 'Bentayan'
group by well
order by max_start_date desc)
on well = well_join and start_date = max_start_date
where structure = 'Bentayan'
order by start_date desc;

/* Inner Join Table */

select datamart.well_test.well, datamart.well_test.test_date as WTEST_DATE, gross_oil_rate as GROSS, net_oil_rate as OIL, water_cut as WC, gas_rate as GAS, tubing_pressure, tubing_temperature, casing_pressure, 
SONOTEST_DATE, psd, dfl, sfl, subm, LIFTING_METHOD, type, jenis_kegiatan, rig_name, start_date, end_date, kategori_kegiatan from datamart.well_test
inner join (select datamart.well_test.well as well_join, max(datamart.well_test.test_date) as max_test_date from datamart.well_test
where structure = 'Bentayan'
group by datamart.well_test.well
order by max_test_date desc)
on datamart.well_test.well = well_join and datamart.well_test.test_date = max_test_date
inner join (select datamart.sonolog.well as well_sono, datamart.sonolog.test_date as SONOTEST_DATE, psd, dfl, sfl, subm from datamart.sonolog
inner join (select datamart.sonolog.well as well_join, max(datamart.sonolog.test_date) as max_test_date from datamart.sonolog
where structure = 'Bentayan'
group by datamart.sonolog.well
order by max_test_date desc)
on datamart.sonolog.well = well_join and datamart.sonolog.test_date = max_test_date
where structure = 'Bentayan'
order by datamart.sonolog.test_date desc)
on datamart.well_test.well = well_sono
inner join (select datamart.well_lifting_data.well as well_liftdata, liftingmethod as LIFTING_METHOD, type from datamart.well_lifting_data
inner join (select datamart.well_lifting_data.well as well_join,max(installdate) as max_installdate from datamart.well_lifting_data
where structure = 'Bentayan' and pulldate is null
group by datamart.well_lifting_data.well
order by max_installdate desc)
on datamart.well_lifting_data.well = well_join and installdate = max_installdate
where structure = 'Bentayan'
order by installdate desc)
on well_sono = well_liftdata
inner join (select datamart.well_job_metric.well as well_job, jenis_kegiatan, rig_name, start_date, end_date, kategori_kegiatan from datamart.well_job_metric
inner join (select datamart.well_job_metric.well as well_join, max(start_date) as max_start_date from datamart.well_job_metric
where structure = 'Bentayan'
group by datamart.well_job_metric.well
order by max_start_date desc)
on datamart.well_job_metric.well = well_join and start_date = max_start_date
where structure = 'Bentayan'
order by start_date desc)
on well_liftdata = well_job
where structure = 'Bentayan'
order by datamart.well_test.test_date desc;

/* Outer Join Table */

select datamart.well_test.well, INTERVAL_PERFORATION, LAST_OFF_DATE, LAST_ON_DATE, OFF_DAYS_BETWEEN, OFF_DURATION_AT_OFFDATE, OFF_DURATION_AT_ONDATE, REASON, well_status, datamart.well_test.test_date as WTEST_DATE, duration as WTEST_DURATION, gross_oil_rate as WTEST_GROSS, net_oil_rate as WTEST_OIL, water_cut as WTEST_WC, gas_rate as WTEST_GAS, 
    case
        when to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') = LAST_ON_DATE Then gross_oil_rate - (OFF_DURATION_AT_ONDATE * gross_oil_rate / 24)
        else gross_oil_rate
    end as TODAY_GROSS,
    case
        when to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') = LAST_ON_DATE Then net_oil_rate - (OFF_DURATION_AT_ONDATE * net_oil_rate / 24)
        else net_oil_rate        
    end as TODAY_OIL,
    case
        when OFF_DURATION_AT_ONDATE = 24 Then Null
        else water_cut
    end as TODAY_WC,
    case
        when to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') = LAST_ON_DATE Then gas_rate - (OFF_DURATION_AT_ONDATE * gas_rate / 24)
        else gas_rate    
    end as TODAY_GAS,
tubing_pressure, tubing_temperature, casing_pressure, 
SONOTEST_DATE, psd, dfl, sfl, subm, LIFTING_METHOD, type, jenis_kegiatan, rig_name, start_date, end_date, kategori_kegiatan from datamart.well_test
inner join (select datamart.well_test.well as well_join, max(datamart.well_test.test_date) as max_test_date from datamart.well_test
where structure = 'Bentayan'
group by datamart.well_test.well
order by max_test_date desc)
on datamart.well_test.well = well_join and datamart.well_test.test_date = max_test_date
full outer join (select well as well_off, date_off as LAST_OFF_DATE, date_on as LAST_ON_DATE, OFF_DAYS_BETWEEN,
    case
        when OFF_DAYS_BETWEEN = -1 Then round(extract(day from (on_date - off_date))*24 + extract(hour from (on_date - off_date)) + 
                                extract(minute from (on_date - off_date))/60 + extract(second from (on_date - off_date))/3600,2)
        else 24.00 - round(extract(hour from(off_date)) + extract(minute from off_date)/60 + extract(second from off_date)/3600,2)
    end as off_duration_at_offdate,
    case
        when OFF_DAYS_BETWEEN = -1 Then 0
        when OFF_DAYS_BETWEEN > -1 and date_on = to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') Then 24
        else round(extract(hour from(on_date)) + extract(minute from on_date)/60 + extract(second from on_date)/3600,2) 
    end as off_duration_at_ondate,
reason from (select well, off_date, on_date, to_date(to_char(cast(off_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') as date_off, nvl(to_date(to_char(cast(on_date as date),'DD-MM-YYYY'),'DD-MM-YYYY'),to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY')) as date_on,
nvl(to_date(to_char(cast(on_date as date),'DD-MM-YYYY'),'DD-MM-YYYY'),to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY')) - to_date(to_char(cast(off_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') - 1 as OFF_DAYS_BETWEEN,
reason from datamart.well_off
inner join (select well as well_join ,max(off_date) as max_off_date from datamart.well_off
where structure = 'Bentayan'
group by well
order by max(off_date) desc)
on well = well_join and off_date = max_off_date
where structure = 'Bentayan'
order by off_date desc))
on datamart.well_test.well = well_off
full outer join (select datamart.sonolog.well as well_sono, datamart.sonolog.test_date as SONOTEST_DATE, psd, dfl, sfl, subm from datamart.sonolog
inner join (select datamart.sonolog.well as well_join, max(datamart.sonolog.test_date) as max_test_date from datamart.sonolog
where structure = 'Bentayan'
group by datamart.sonolog.well
order by max_test_date desc)
on datamart.sonolog.well = well_join and datamart.sonolog.test_date = max_test_date
where structure = 'Bentayan'
order by datamart.sonolog.test_date desc)
on datamart.well_test.well = well_sono
full outer join (select datamart.well_job_metric.well as well_job, jenis_kegiatan, rig_name, start_date, end_date, kategori_kegiatan from datamart.well_job_metric
inner join (select datamart.well_job_metric.well as well_join, max(start_date) as max_start_date from datamart.well_job_metric
where structure = 'Bentayan'
group by datamart.well_job_metric.well
order by max_start_date desc)
on datamart.well_job_metric.well = well_join and start_date = max_start_date
where structure = 'Bentayan'
order by start_date desc)
on datamart.well_test.well = well_job
full outer join (select datamart.well_lifting_data.well as well_liftdata, liftingmethod as LIFTING_METHOD, type from datamart.well_lifting_data
inner join (select datamart.well_lifting_data.well as well_join,max(installdate) as max_installdate from datamart.well_lifting_data
where structure = 'Bentayan' and pulldate is null
group by datamart.well_lifting_data.well
order by max_installdate desc)
on datamart.well_lifting_data.well = well_join and installdate = max_installdate
where structure = 'Bentayan'
order by installdate desc)
on datamart.well_test.well = well_liftdata
full outer join (select well as well_interval_perfo, listagg(PERFO_INTERVAL, '; ') within group (order by top_perf) as INTERVAL_PERFORATION from (select well, perforate_date, top_perf, bot_perf, to_char(top_perf) || ' - ' || to_char(bot_perf) || ' (' || layer || ')' as PERFO_INTERVAL, status_date, status, layer from datamart.perforation_status
inner join (select well as well_join, perforate_date as perf_date_join, top_perf as top_join, bot_perf as bot_join, max(status_date) as max_status_date from datamart.perforation_status
where structure = 'Bentayan'
group by well, perforate_date, top_perf, bot_perf)
on well = well_join and perforate_date = perf_date_join and top_perf = top_join and bot_perf = bot_join and status_date = max_status_date
where status = 'OPEN'
order by well asc, top_perf asc)
group by well
order by well asc)
on datamart.well_test.well = well_interval_perfo
full outer join (select well as well_laststatus, well_status from datamart.well_last_data
where structure = 'Bentayan')
on datamart.well_test.well = well_laststatus
where structure = 'Bentayan'
order by datamart.well_test.well asc;

select * from datamart.well_off;
select well as well_max, max(off_date) as off_date_max from datamart.well_off
group by well;

/* Fix Well Off */
select well as well_off,
    case
        when to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') > to_date(to_char(cast(off_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') and on_date is null Then 0
        when to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') > to_date(to_char(cast(off_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') and to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') > to_date(to_char(cast(on_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') Then 0
        when to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') > to_date(to_char(cast(off_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') and to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') = to_date(to_char(cast(on_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') Then
            24 - round(extract(hour from(on_date)) + extract(minute from on_date)/60 + extract(second from on_date)/3600,2)
        else 24
    end as prod_hours,
reason as off_reason
from datamart.well_off
inner join (select well as well_max, max(off_date) as off_date_max from datamart.well_off
group by well)
on well = well_max and off_date = off_date_max;

select * from (select datamart.well_test.asset as asset, datamart.well_test.area as area, datamart.well_test.structure as structure, datamart.well_test.well as wtest_well, interval_perforation, datamart.well_test.test_date as wtest_testdate, duration as wtets_duration, gross_oil_rate as gross,
net_oil_rate as oil, water_cut as wc, gas_rate as gas, prod_hours, gross_oil_rate * prod_hours / 24 as today_gross, net_oil_rate * prod_hours / 24 as today_oil, 
    case
        when prod_hours > 0 Then water_cut
        else Null
    end as today_wc, 
gas_rate * prod_hours / 24 as today_gas,  tubing_pressure as Pt, tubing_temperature as Ptemp, casing_pressure as Pc,
sono_testdate, psd, dfl, sfl, subm, lifting_method, type, dyna_testdate, sl, spm, pump_displacement, off_reason from datamart.well_test
inner join (select well as well_max_wtest, max(test_date) as max_testdate_wtest from datamart.well_test
group by datamart.well_test.well)
on datamart.well_test.well = well_max_wtest and test_date = max_testdate_wtest
inner join
(select well as lastdata_well, well_status from datamart.well_last_data
where well_status like 'Active%' and wtestdate is not null)
on datamart.well_test.well = lastdata_well
inner join (select well as well_off,
    case
        when to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') > to_date(to_char(cast(off_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') and on_date is null Then 0
        when to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') > to_date(to_char(cast(off_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') and to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') > to_date(to_char(cast(on_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') Then 24
        when to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') > to_date(to_char(cast(off_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') and to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') = to_date(to_char(cast(on_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') Then
            24 - round(extract(hour from(on_date)) + extract(minute from on_date)/60 + extract(second from on_date)/3600,2)
    end as prod_hours,
reason as off_reason
from datamart.well_off
inner join (select well as well_max, max(off_date) as off_date_max from datamart.well_off
group by well)
on well = well_max and off_date = off_date_max)
on datamart.well_test.well = well_off
full outer join (select datamart.sonolog.well as well_sono, datamart.sonolog.test_date as sono_testdate, psd, dfl, sfl, subm from datamart.sonolog
inner join (select datamart.sonolog.well as well_join, max(datamart.sonolog.test_date) as max_test_date from datamart.sonolog
group by datamart.sonolog.well)
on datamart.sonolog.well = well_join and datamart.sonolog.test_date = max_test_date)
on datamart.well_test.well = well_sono
full outer join (select well as well_interval_perfo, listagg(PERFO_INTERVAL, '; ') within group (order by top_perf) as INTERVAL_PERFORATION from (select well, perforate_date, top_perf, bot_perf, to_char(top_perf) || ' - ' || to_char(bot_perf) || ' (' || layer || ')' as PERFO_INTERVAL, status_date, status, layer from datamart.perforation_status
inner join (select well as well_join, perforate_date as perf_date_join, top_perf as top_join, bot_perf as bot_join, max(status_date) as max_status_date from datamart.perforation_status
group by well, perforate_date, top_perf, bot_perf)
on well = well_join and perforate_date = perf_date_join and top_perf = top_join and bot_perf = bot_join and status_date = max_status_date
where status = 'OPEN')
group by well)
on datamart.well_test.well = well_interval_perfo
full outer join (select datamart.well_lifting_data.well as well_liftdata, liftingmethod as LIFTING_METHOD, type from datamart.well_lifting_data
inner join (select datamart.well_lifting_data.well as well_join,max(installdate) as max_installdate from datamart.well_lifting_data
where pulldate is null
group by datamart.well_lifting_data.well)
on datamart.well_lifting_data.well = well_join and installdate = max_installdate)
on datamart.well_test.well = well_liftdata
full outer join (select datamart.well_dynagraph.well as well_dyna, test_date as dyna_testdate, sl, spm, pump_displacement from datamart.well_dynagraph
inner join (select well as welldyna_max, max(test_date) as max_testdate_dyna from datamart.well_dynagraph
group by datamart.well_dynagraph.well)
on well = welldyna_max and test_date = max_testdate_dyna)
on datamart.well_test.well = well_dyna) where wtest_well is not null
order by asset asc, area asc, structure asc, wtest_well asc;


select asset, area, structure, well, interval_perforation, test_date, winj, waterthp as whp from datamart.winj_test
inner join (select well as well_max, max(test_date) as max_testdate from datamart.winj_test
group by datamart.winj_test.well)
on well = well_max and test_date = max_testdate
full outer join (select well as well_interval_perfo, listagg(PERFO_INTERVAL, '; ') within group (order by top_perf) as INTERVAL_PERFORATION from (select well, perforate_date, top_perf, bot_perf, to_char(top_perf) || ' - ' || to_char(bot_perf) || ' (' || layer || ')' as PERFO_INTERVAL, status_date, status, layer from datamart.perforation_status
inner join (select well as well_join, perforate_date as perf_date_join, top_perf as top_join, bot_perf as bot_join, max(status_date) as max_status_date from datamart.perforation_status
group by well, perforate_date, top_perf, bot_perf)
on well = well_join and perforate_date = perf_date_join and top_perf = top_join and bot_perf = bot_join and status_date = max_status_date
where status = 'OPEN')
group by well)
on datamart.winj_test.well = well_interval_perfo
where test_date >= current_date - 2 and well is not null
order by asset asc, area asc, structure asc, well asc;
/* Prod Daily Report New */
select datamart.well_test.well, INTERVAL_PERFORATION, LAST_OFF_DATE, LAST_ON_DATE, OFF_DAYS_BETWEEN, OFF_DURATION_AT_OFFDATE, OFF_DURATION_AT_ONDATE, REASON, well_status, datamart.well_test.test_date as WTEST_DATE, duration as WTEST_DURATION, gross_oil_rate as WTEST_GROSS, net_oil_rate as WTEST_OIL, water_cut as WTEST_WC, gas_rate as WTEST_GAS, 
    case
        when to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') = LAST_ON_DATE Then gross_oil_rate - (OFF_DURATION_AT_ONDATE * gross_oil_rate / 24)
        else gross_oil_rate
    end as TODAY_GROSS,
    case
        when to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') = LAST_ON_DATE Then net_oil_rate - (OFF_DURATION_AT_ONDATE * net_oil_rate / 24)
        else net_oil_rate        
    end as TODAY_OIL,
    case
        when OFF_DURATION_AT_ONDATE = 24 Then Null
        else water_cut
    end as TODAY_WC,
    case
        when to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') = LAST_ON_DATE Then gas_rate - (OFF_DURATION_AT_ONDATE * gas_rate / 24)
        else gas_rate    
    end as TODAY_GAS,
tubing_pressure, tubing_temperature, casing_pressure, 
SONOTEST_DATE, psd, dfl, sfl, subm, LIFTING_METHOD, type, jenis_kegiatan, rig_name, start_date, end_date, kategori_kegiatan from datamart.well_test
inner join (select datamart.well_test.well as well_join, max(datamart.well_test.test_date) as max_test_date from datamart.well_test
where structure = 'Bentayan'
group by datamart.well_test.well
order by max_test_date desc)
on datamart.well_test.well = well_join and datamart.well_test.test_date = max_test_date
full outer join (select well as well_off, date_off as LAST_OFF_DATE, date_on as LAST_ON_DATE, OFF_DAYS_BETWEEN,
    case
        when OFF_DAYS_BETWEEN = -1 Then round(extract(day from (on_date - off_date))*24 + extract(hour from (on_date - off_date)) + 
                                extract(minute from (on_date - off_date))/60 + extract(second from (on_date - off_date))/3600,2)
        else 24.00 - round(extract(hour from(off_date)) + extract(minute from off_date)/60 + extract(second from off_date)/3600,2)
    end as off_duration_at_offdate,
    case
        when OFF_DAYS_BETWEEN = -1 Then 0
        when OFF_DAYS_BETWEEN > -1 and date_on = to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY') Then 24
        else round(extract(hour from(on_date)) + extract(minute from on_date)/60 + extract(second from on_date)/3600,2) 
    end as off_duration_at_ondate,
reason from (select well, off_date, on_date, to_date(to_char(cast(off_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') as date_off, nvl(to_date(to_char(cast(on_date as date),'DD-MM-YYYY'),'DD-MM-YYYY'),to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY')) as date_on,
nvl(to_date(to_char(cast(on_date as date),'DD-MM-YYYY'),'DD-MM-YYYY'),to_date(to_char(current_date - 1,'DD-MM-YYYY'),'DD-MM-YYYY')) - to_date(to_char(cast(off_date as date),'DD-MM-YYYY'),'DD-MM-YYYY') - 1 as OFF_DAYS_BETWEEN,
reason from datamart.well_off
inner join (select well as well_join ,max(off_date) as max_off_date from datamart.well_off
where structure = 'Bentayan'
group by well
order by max(off_date) desc)
on well = well_join and off_date = max_off_date
where structure = 'Bentayan'
order by off_date desc))
on datamart.well_test.well = well_off
full outer join (select datamart.sonolog.well as well_sono, datamart.sonolog.test_date as SONOTEST_DATE, psd, dfl, sfl, subm from datamart.sonolog
inner join (select datamart.sonolog.well as well_join, max(datamart.sonolog.test_date) as max_test_date from datamart.sonolog
where structure = 'Bentayan'
group by datamart.sonolog.well
order by max_test_date desc)
on datamart.sonolog.well = well_join and datamart.sonolog.test_date = max_test_date
where structure = 'Bentayan'
order by datamart.sonolog.test_date desc)
on datamart.well_test.well = well_sono
full outer join (select datamart.well_job_metric.well as well_job, jenis_kegiatan, rig_name, start_date, end_date, kategori_kegiatan from datamart.well_job_metric
inner join (select datamart.well_job_metric.well as well_join, max(start_date) as max_start_date from datamart.well_job_metric
where structure = 'Bentayan'
group by datamart.well_job_metric.well
order by max_start_date desc)
on datamart.well_job_metric.well = well_join and start_date = max_start_date
where structure = 'Bentayan'
order by start_date desc)
on datamart.well_test.well = well_job
full outer join (select datamart.well_lifting_data.well as well_liftdata, liftingmethod as LIFTING_METHOD, type from datamart.well_lifting_data
inner join (select datamart.well_lifting_data.well as well_join,max(installdate) as max_installdate from datamart.well_lifting_data
where structure = 'Bentayan' and pulldate is null
group by datamart.well_lifting_data.well
order by max_installdate desc)
on datamart.well_lifting_data.well = well_join and installdate = max_installdate
where structure = 'Bentayan'
order by installdate desc)
on datamart.well_test.well = well_liftdata
full outer join (select well as well_interval_perfo, listagg(PERFO_INTERVAL, '; ') within group (order by top_perf) as INTERVAL_PERFORATION from (select well, perforate_date, top_perf, bot_perf, to_char(top_perf) || ' - ' || to_char(bot_perf) || ' (' || layer || ')' as PERFO_INTERVAL, status_date, status, layer from datamart.perforation_status
inner join (select well as well_join, perforate_date as perf_date_join, top_perf as top_join, bot_perf as bot_join, max(status_date) as max_status_date from datamart.perforation_status
where structure = 'Bentayan'
group by well, perforate_date, top_perf, bot_perf)
on well = well_join and perforate_date = perf_date_join and top_perf = top_join and bot_perf = bot_join and status_date = max_status_date
where status = 'OPEN'
order by well asc, top_perf asc)
group by well
order by well asc)
on datamart.well_test.well = well_interval_perfo
full outer join (select well as well_laststatus, well_status from datamart.well_last_data
where structure = 'Bentayan')
on datamart.well_test.well = well_laststatus
where structure = 'Bentayan'
order by datamart.well_test.well asc;

/* End */
select datamart.well_properties.well, layer, topmd, botmd, net_thick, perm, poro, sw from datamart.well_properties
inner join datamart.well_last_data
on datamart.well_properties.uwi = datamart.well_last_data.uwi
where structure = 'Bentayan'
order by well asc, topmd asc;

select well, status_date, top_perf, bot_perf, status, perforate_date from datamart.perforation_status
where structure = 'Tanjung (WF/SecRec)'
order by well asc, status_date desc;

select table1.well, table1.perforate_date, table1.top_perf, table1.bot_perf, table1.status_date, table1.status, table2.status_date, table2.status from datamart.perforation_status table1
inner join datamart.perforation_status table2
on table1.top_perf = table2.bot_perf and table1.perforate_date = table2.perforate_date and table1.status != table2.status
where table1.structure = 'Tanjung (WF/SecRec)'
order by table1.well asc, table1.status_date asc;

select well as well_interval_perfo, listagg(PERFO_INTERVAL, '; ') within group (order by top_perf) as INTERVAL_PERFORATION from (select well, perforate_date, top_perf, bot_perf, to_char(top_perf) || ' - ' || to_char(bot_perf) || ' (' || layer || ')' as PERFO_INTERVAL, status_date, status, layer from datamart.perforation_status
inner join (select well as well_join, perforate_date as perf_date_join, top_perf as top_join, bot_perf as bot_join, max(status_date) as max_status_date from datamart.perforation_status
where structure = 'Tanjung (WF/SecRec)'
group by well, perforate_date, top_perf, bot_perf)
on well = well_join and perforate_date = perf_date_join and top_perf = top_join and bot_perf = bot_join and status_date = max_status_date
where status = 'OPEN'
order by well asc, top_perf asc)
group by well
order by well asc;

select well, well_status from datamart.well_last_data
where structure = 'Tanjung (WF/SecRec)';

select well, INTERVAL_PERFORATION, test_date as last_test_date, winj, waterthp as WHP, jenis_kegiatan, rig_name, start_date, end_date, kategori_kegiatan from datamart.winj_test
inner join (select well well_join,max(test_date) as max_test_date from datamart.winj_test
where structure = 'Niru'
group by well
order by well asc)
on well = well_join and test_date = max_test_date
full outer join (select well as well_interval_perfo, listagg(PERFO_INTERVAL, '; ') within group (order by top_perf) as INTERVAL_PERFORATION from (select well, perforate_date, top_perf, bot_perf, to_char(top_perf) || ' - ' || to_char(bot_perf) || ' (' || layer || ')' as PERFO_INTERVAL, status_date, status, layer from datamart.perforation_status
inner join (select well as well_join, perforate_date as perf_date_join, top_perf as top_join, bot_perf as bot_join, max(status_date) as max_status_date from datamart.perforation_status
where structure = 'Niru'
group by well, perforate_date, top_perf, bot_perf)
on well = well_join and perforate_date = perf_date_join and top_perf = top_join and bot_perf = bot_join and status_date = max_status_date
where status = 'OPEN'
order by well asc, top_perf asc)
group by well
order by well asc)
on datamart.winj_test.well = well_interval_perfo
full outer join (select datamart.well_job_metric.well as well_job, jenis_kegiatan, rig_name, start_date, end_date, kategori_kegiatan from datamart.well_job_metric
inner join (select datamart.well_job_metric.well as well_join, max(start_date) as max_start_date from datamart.well_job_metric
where structure = 'Niru'
group by datamart.well_job_metric.well
order by max_start_date desc)
on datamart.well_job_metric.well = well_join and start_date = max_start_date
where structure = 'Niru'
order by start_date desc)
on datamart.winj_test.well = well_job
where datamart.winj_test.well is not null and winj is not null and winj != 0 and to_date(to_char(test_date,'DD-MM-YYYY'),'DD-MM-YYYY')  = to_date(to_char(current_date - 2, 'DD-MM-YYYY'),'DD-MM-YYYY');

select * from datamart.well_last_data
where structure = 'Niru' and well_type = 'Injeksi';

select * from datamart.perforation_status
where structure = 'Rantau';

/* Statistic Data */

/* Well Job Frequency by Structure */

select period_service as Month_Period, nvl(well_service_freq, 0) as well_service_freq, nvl(intervention_freq, 0) as intervention_freq, nvl(work_over_freq, 0) as work_over_freq, nvl(drilling_freq,0) as drilling_freq 
from (select to_char(start_date,'MM-YYYY') as period_service, count(*) as well_service_freq from datamart.well_job_metric
where structure = 'Tanjung (WF/SecRec)' and jenis_kegiatan = 'WELL SERVICE'
group by to_char(start_date,'MM-YYYY'))
full outer join (select to_char(start_date,'MM-YYYY') as period_intervention, count(*) as intervention_freq from datamart.well_job_metric
where structure = 'Tanjung (WF/SecRec)' and jenis_kegiatan = 'INTERVENTION'
group by to_char(start_date,'MM-YYYY'))
on period_service = period_intervention
full outer join (select to_char(start_date,'MM-YYYY') as period_wo, count(*) as work_over_freq from datamart.well_job_metric
where structure = 'Tanjung (WF/SecRec)' and jenis_kegiatan = 'WORK OVER'
group by to_char(start_date,'MM-YYYY'))
on period_service = period_wo
full outer join (select to_char(start_date,'MM-YYYY') as period_drilling, count(*) as drilling_freq from datamart.well_job_metric
where structure = 'Tanjung (WF/SecRec)' and jenis_kegiatan = 'DRILLING'
group by to_char(start_date,'MM-YYYY'))
on period_service = period_drilling
order by substr(period_service,4,4) asc, substr(period_service,1,2) asc;

select distinct(structure) from (select * from datamart.well_job where total_cost > 0) order by structure asc;
select to_char(start_date,'MM-YYYY') as month_period,
    sum(case jenis_kegiatan
            when 'WELL SERVICE' Then 1
            else 0
        end) as well_service_freq,
    sum(case jenis_kegiatan
            when 'INTERVENTION' Then 1
            else 0
        end) as intervention_freq,
    sum(case jenis_kegiatan
            when 'WORK OVER' Then 1
            else 0
        end) as work_over_freq,
    sum(case jenis_kegiatan
            when 'DRILLING' Then 1
            else 0
        end) as drilling_freq,
    sum(case jenis_kegiatan
            when 'WELL SERVICE' Then total_cost
            else 0
        end) as well_service_total_cost,
    sum(case jenis_kegiatan
            when 'INTERVENTION' Then total_cost
            else 0
        end) as intervention_total_cost,
    sum(case jenis_kegiatan
            when 'WORK OVER' Then total_cost
            else 0
        end) as work_over_cost,
    sum(case jenis_kegiatan
            when 'DRILLING' Then total_cost
            else 0
        end) as drilling_total_cost
from datamart.well_job
where structure = 'Tanjung (WF/SecRec)'
group by to_char(start_date,'MM-YYYY')
having to_char(start_date,'MM-YYYY') is not null
order by substr(month_period,4,4) asc, substr(month_period,1,2) asc;

/* Surveillance Freq */

/* Well Test */
select to_char(test_date,'MM-YYYY') as month_period_wtest,
    sum(case
            when gross_oil_rate is not null Then 1
            else 0
        end) as prodrate_freq,
    sum(case 
            when gross_oil_rate is not null and tubing_pressure is not null Then 1
            else 0
        end) as wellhead_press_freq,
    sum(case
            when gross_oil_rate is not null and tubing_temperature is not null Then 1
            else 0
        end) as wellhead_temp_freq,
    sum(case
            when gross_oil_rate is not null and casing_pressure is not null Then 1
            else 0
        end) as casing_press_freq
from datamart.well_test
where structure = 'Niru'
group by to_char(test_date,'MM-YYYY')
order by substr(month_period_wtest,4,4) asc, substr(month_period_wtest,1,2) asc;

/* Sonolog */
select to_char(test_date,'MM-YYYY') as month_period_sono,
    sum(case
            when dfl is not null and sfl is null Then 1
            else 0
        end) as DFL_freq,
    sum(case
            when dfl is null and sfl is not null Then 1
            else 0
        end) as SFL_freq
from datamart.sonolog
where structure = 'Niru'
group by to_char(test_date,'MM-YYYY')
order by substr(month_period_sono,4,4) asc, substr(month_period_sono,1,2) asc;

/* Inj_Test */
select to_char(test_date,'MM-YYYY') as month_period_injtest,
    sum(case
            when winj is not null Then 1
            else 0
        end) as injrate_freq,
    sum(case
            when waterthp is not null Then 1
            else 0
        end) as whp_freq
from datamart.winj_test
where structure = 'Niru'
group by to_char(test_date,'MM-YYYY')
order by substr(month_period_injtest,4,4) asc, substr(month_period_injtest,1,2) asc;

/* Dynagraph */
select to_char(test_date,'MM-YYYY') as month_period_dyna,
    sum(case
            when spm is not null Then 1
            else 0
        end) as dyna_freq
from datamart.well_dynagraph
where structure = 'Talang Jimar'
group by to_char(test_date,'MM-YYYY')
order by substr(month_period_dyna,4,4) asc, substr(month_period_dyna,1,2) asc;

/* Join Surveillance Statistic */
select month_period_wtest, prodrate_freq, wellhead_press_freq,
wellhead_temp_freq, casing_press_freq, DFL_freq, SFL_freq, injrate_freq, injwhp_freq from
(select to_char(test_date,'MM-YYYY') as month_period_wtest,
    sum(case
            when gross_oil_rate is not null Then 1
            else 0
        end) as prodrate_freq,
    sum(case 
            when gross_oil_rate is not null and tubing_pressure is not null Then 1
            else 0
        end) as wellhead_press_freq,
    sum(case
            when gross_oil_rate is not null and tubing_temperature is not null Then 1
            else 0
        end) as wellhead_temp_freq,
    sum(case
            when gross_oil_rate is not null and casing_pressure is not null Then 1
            else 0
        end) as casing_press_freq
from datamart.well_test where 
structure = 'Niru'
group by to_char(test_date,'MM-YYYY')
order by substr(month_period_wtest,4,4) asc, substr(month_period_wtest,1,2) asc)
full outer join (select to_char(test_date,'MM-YYYY') as month_period_sono,
    sum(case
            when dfl is not null and sfl is null Then 1
            else 0
        end) as DFL_freq,
    sum(case
            when dfl is null and sfl is not null Then 1
            else 0
        end) as SFL_freq
from datamart.sonolog where 
structure = 'Niru'
group by to_char(test_date,'MM-YYYY')
order by substr(month_period_sono,4,4) asc, substr(month_period_sono,1,2) asc)
on month_period_wtest = month_period_sono
full outer join (select to_char(test_date,'MM-YYYY') as month_period_injtest,
    sum(case
            when winj is not null Then 1
            else 0
        end) as injrate_freq,
    sum(case
            when waterthp is not null Then 1
            else 0
        end) as injwhp_freq
from datamart.winj_test where 
structure = 'Niru'
group by to_char(test_date,'MM-YYYY')
order by substr(month_period_injtest,4,4) asc, substr(month_period_injtest,1,2) asc)
on month_period_wtest = month_period_injtest
where month_period_wtest is not null;

select month_period_wtest, prodrate_freq, wellhead_press_freq,
wellhead_temp_freq, casing_press_freq, DFL_freq, SFL_freq, injrate_freq, injwhp_freq, dyna_freq from
(select to_char(test_date,'MM-YYYY') as month_period_wtest,
    sum(case
            when gross_oil_rate is not null Then 1
            else 0
        end) as prodrate_freq,
    sum(case 
            when gross_oil_rate is not null and tubing_pressure is not null Then 1
            else 0
        end) as wellhead_press_freq,
    sum(case
            when gross_oil_rate is not null and tubing_temperature is not null Then 1
            else 0
        end) as wellhead_temp_freq,
    sum(case
            when gross_oil_rate is not null and casing_pressure is not null Then 1
            else 0
        end) as casing_press_freq
from datamart.well_test where area = 'Limau' group by to_char(test_date,'MM-YYYY')
order by substr(month_period_wtest,4,4) asc, substr(month_period_wtest,1,2) asc)
full outer join (select to_char(test_date,'MM-YYYY') as month_period_sono,
    sum(case
            when dfl is not null and sfl is null Then 1
            else 0
        end) as DFL_freq,
    sum(case
            when dfl is null and sfl is not null Then 1
            else 0
        end) as SFL_freq
from datamart.sonolog where area = 'Limau' group by to_char(test_date,'MM-YYYY')
order by substr(month_period_sono,4,4) asc, substr(month_period_sono,1,2) asc)
on month_period_wtest = month_period_sono
full outer join (select to_char(test_date,'MM-YYYY') as month_period_injtest,
    sum(case
            when winj is not null Then 1
            else 0
        end) as injrate_freq,
    sum(case
            when waterthp is not null Then 1
            else 0
        end) as injwhp_freq
from datamart.winj_test where area = 'Limau' group by to_char(test_date,'MM-YYYY')
order by substr(month_period_injtest,4,4) asc, substr(month_period_injtest,1,2) asc)
on month_period_wtest = month_period_injtest
where month_period_wtest is not null;

select to_char(start_date,'MM-YYYY') as month_period,
    sum(case jenis_kegiatan
            when 'WELL SERVICE' Then 1
            else 0
        end) as well_service_freq,
    sum(case jenis_kegiatan
            when 'INTERVENTION' Then 1
            else 0
        end) as intervention_freq,
    sum(case jenis_kegiatan
            when 'WORK OVER' Then 1
            else 0
        end) as work_over_freq,
    sum(case jenis_kegiatan
            when 'DRILLING' Then 1
            else 0
        end) as drilling_freq,
    sum(case jenis_kegiatan
            when 'WELL SERVICE' Then total_cost
            else 0
        end) as well_service_total_cost,
    sum(case jenis_kegiatan
            when 'INTERVENTION' Then total_cost
            else 0
        end) as intervention_total_cost,
    sum(case jenis_kegiatan
            when 'WORK OVER' Then total_cost
            else 0
        end) as work_over_cost,
    sum(case jenis_kegiatan
            when 'DRILLING' Then total_cost
            else 0
        end) as drilling_total_cost
from datamart.well_job
where structure = 'Tanjung (WF/SecRec)'
group by to_char(start_date,'MM-YYYY')
having to_char(start_date,'MM-YYYY') is not null
order by substr(month_period,4,4) asc, substr(month_period,1,2) asc;

/* Well Job Detail */

select well as well_max, max(start_date) as max_start_date from datamart.well_job
where structure = 'Tanjung (WF/SecRec)'
group by well
order by well asc;

/* Original */

select well, jenis_kegiatan, kategori_kegiatan, kegiatan, rig_name, effdate, periode, description from datamart.well_job_daily_detail
inner join (select well as well_target, afe_no as afe_no_target from datamart.well_job
inner join (select well as well_max, max(start_date) as max_start_date from datamart.well_job
where structure = 'Tanjung (WF/SecRec)'
group by well
order by well asc)
on well = well_max and start_date = max_start_date
where structure = 'Tanjung (WF/SecRec)')
on afe_no = afe_no_target
where well = 'PRD-017' and effdate = '25-01-2020';

/* Main Info */

select well, jenis_kegiatan, kategori_kegiatan, kegiatan, rig_name, effdate, periode, description from datamart.well_job_daily_detail
inner join (select well as well_target, afe_no as afe_no_target from datamart.well_job
inner join (select well as well_max, max(start_date) as max_start_date from datamart.well_job
where structure = 'Tanjung (WF/SecRec)'
group by well
order by well asc)
on well = well_max and start_date = max_start_date
where structure = 'Tanjung (WF/SecRec)')
on afe_no = afe_no_target;
--asset selection
select distinct(asset) from datamart.well_job
order by asset asc;
--structure selection
select distinct(structure) from datamart.well_job
where asset = 'Asset 5'
order by structure asc;
--well selection
select distinct(well) from datamart.well_job_daily_detail
inner join (select well as well_target, afe_no as afe_no_target from datamart.well_job
inner join (select well as well_max, max(start_date) as max_start_date from datamart.well_job
where structure = 'Tanjung (WF/SecRec)'
group by well
order by well asc)
on well = well_max and start_date = max_start_date
where structure = 'Tanjung (WF/SecRec)')
on afe_no = afe_no_target
order by well asc;
-- effdate selection
select distinct(effdate) from datamart.well_job_daily_detail
inner join (select afe_no as afe_no_target from datamart.well_job
inner join (select max(start_date) as max_start_date from datamart.well_job
where well = 'T-089')
on start_date = max_start_date
where well = 'T-089')
on afe_no = afe_no_target
where well = 'T-089'
order by effdate asc;

select jenis_kegiatan, rig_name, kategori_kegiatan, periode, description from datamart.well_job_daily_detail
inner join (select afe_no as afe_no_target from datamart.well_job
inner join (select max(start_date) as max_start_date from datamart.well_job
where well = 'L5A-286')
on start_date = max_start_date
where well = 'L5A-286')
on afe_no = afe_no_target
where well = 'L5A-286' 
and effdate = '17-06-2019'
order by substr(periode,1,5) asc;

select afe_no as af_no_target from datamart.well_job
inner join (select max(start_date) as max_start_date from datamart.well_job
where well = 'T-089')
on start_date = max_start_date
where well = 'T-089';


select well as well_target, afe_no as afe_no_target from datamart.well_job
inner join (select well as well_max, max(start_date) as max_start_date from datamart.well_job
where structure = 'Tanjung (WF/SecRec)'
group by well
order by well asc)
on well = well_max and start_date = max_start_date
where structure = 'Tanjung (WF/SecRec)';

/* Lifting Data */

select * from datamart.well_lifting_data;

select distinct(liftingmethod) from datamart.well_lifting_data;

select type, count(*) from datamart.well_lifting_data
where liftingmethod = 'SRP (Sucker Rod Pump)' and pulldate is not null
group by type;

select type, count(*) from datamart.well_lifting_data
where liftingmethod = 'ESP (Electric Submersible Pump)' and pulldate is not null
group by type;

select type, count(*) from datamart.well_lifting_data
where liftingmethod = 'Injection Stri' and pulldate is not null
group by type;

select distinct(area) from datamart.well_job
where asset = 'Asset 5';

select * from datamart.well_job_daily_detail
where well = 'R-059' and jenis_kegiatan = 'DRILLING';

select * from datamart.well_job_daily_detail
where well like 'JRK-%' and kategori_kegiatan like '%EOR%'
order by effdate desc;

/* --- */
select distinct(well), effdate, rig_name, jenis_kegiatan, kategori_kegiatan from datamart.well_job_daily_detail
inner join (select well as well_max, max(effdate) as max_effdate from datamart.well_job_daily_detail
group by well)
on well = well_max and effdate = max_effdate
where effdate > current_date - 2
order by well asc;

select * from datamart.well_test
where structure = 'Rantau'
order by test_date desc;
select * from datamart.perforation_status
where structure = 'Rantau'
order by status_date desc;
select distinct(version) from datamart.well_properties;
select * from datamart.well_properties
where version = 'PETREL_EOR_RANTAU';

select * from datamart.well_test
where well = 'P-348'
order by test_date;
select * from datamart.perforation_status
where well = 'P-348'
order by status_date asc;
select well, topmd, botmd, layer from datamart.well_properties
where well = 'P-348'
order by topmd asc;

/* Execute */
select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,final_layer from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as final_layer from datamart.well_properties)
on well = well_prf
where well = 'P-348'
order by top_perf asc,status asc;

select well, status_date, top_perf,bot_perf,status,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd Then 1
        else -1
    end as layer_check,
topmd,botmd,final_layer from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,final_layer from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as final_layer from datamart.well_properties)
on well = well_prf
where well = 'T-004'
order by top_perf asc, status asc);

select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
where well = 'T-089'
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc;

select structure,well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
where well = 'T-089'
order by prod_date asc;

select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
where well = 'T-089'
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc;

select * from (select structure,well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
order by prod_date asc, status_date desc)
where split_check = 1 and
well = 'T-089';

select prod_date as max_proddate,perforate_date as max_perfdate,top_perf as max_topperf,bot_perf as max_botperf,max(status_date) as max_statdate from
(select * from (select well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
where well = 'T-089'
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
where well = 'T-089'
order by prod_date asc, status_date desc)
where split_check = 1)
group by prod_date,perforate_date,top_perf,bot_perf
order by prod_date asc,perforate_date asc;

select * from (select * from (select structure,well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
order by prod_date asc, status_date desc)
where split_check = 1)
inner join (select well as max_well, prod_date as max_proddate,perforate_date as max_perfdate,top_perf as max_topperf,bot_perf as max_botperf,max(status_date) as max_statdate from
(select * from (select structure,well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
order by prod_date asc, status_date desc)
where split_check = 1)
group by well,prod_date,perforate_date,top_perf,bot_perf)
on well = max_well and prod_date = max_proddate and perforate_date = max_perfdate and top_perf = max_topperf and bot_perf = max_botperf and status_date = max_statdate
where well = 'T-089'
order by well asc,prod_date asc,perforate_date asc;

select distinct(updated_layer),well,prod_date,dayson,gross,oil,water,gas,wcut,net_thick,perm,net_thick * perm as kh from (select * from (select * from (select structure,well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
order by prod_date asc, status_date desc)
where split_check = 1)
inner join (select well as max_well, prod_date as max_proddate,perforate_date as max_perfdate,top_perf as max_topperf,bot_perf as max_botperf,max(status_date) as max_statdate from
(select * from (select structure,well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
order by prod_date asc, status_date desc)
where split_check = 1)
group by well,prod_date,perforate_date,top_perf,bot_perf)
on well = max_well and prod_date = max_proddate and perforate_date = max_perfdate and top_perf = max_topperf and bot_perf = max_botperf and status_date = max_statdate
order by well asc,prod_date asc,perforate_date asc)
where status = 'OPEN' and
well = 'T-089';

select distinct(updated_layer),well,prod_date,dayson,gross,oil,water,gas,wcut,net_thick,perm,net_thick * perm as kh from (select * from (select * from (select well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
where well = 'T-089'
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
where well = 'T-089'
order by prod_date asc, status_date desc)
where split_check = 1)
inner join (select prod_date as max_proddate,perforate_date as max_perfdate,top_perf as max_topperf,bot_perf as max_botperf,max(status_date) as max_statdate from
(select * from (select well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
where well = 'T-089'
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
where well = 'T-089'
order by prod_date asc, status_date desc)
where split_check = 1)
group by prod_date,perforate_date,top_perf,bot_perf)
on prod_date = max_proddate and perforate_date = max_perfdate and top_perf = max_topperf and bot_perf = max_botperf and status_date = max_statdate
order by prod_date asc,perforate_date asc)
where status = 'OPEN'
order by prod_date asc;

select well as well_kh, prod_date as proddate_kh, sum(kh) as total_kh from
(select distinct(updated_layer),well,prod_date,dayson,gross,oil,water,gas,wcut,net_thick,perm,net_thick * perm as kh from (select * from (select * from (select structure,well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
order by prod_date asc, status_date desc)
where split_check = 1)
inner join (select well as max_well, prod_date as max_proddate,perforate_date as max_perfdate,top_perf as max_topperf,bot_perf as max_botperf,max(status_date) as max_statdate from
(select * from (select structure,well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
order by prod_date asc, status_date desc)
where split_check = 1)
group by well,prod_date,perforate_date,top_perf,bot_perf)
on well = max_well and prod_date = max_proddate and perforate_date = max_perfdate and top_perf = max_topperf and bot_perf = max_botperf and status_date = max_statdate
order by well asc,prod_date asc,perforate_date asc)
where status = 'OPEN')
where well = 'T-089'
group by well,prod_date
order by prod_date;

/* Beta */
select well,updated_layer as layer,prod_date,dayson,round(kh/kh_total*gross,2) as gross_split,round(kh/kh_total*oil,2) as oil_split,round(kh/kh_total*water,2) as water_split,round(kh/kh_total*gas,2) as gas_split,
    case
        when gross = 0 Then Null
        else round(wcut,2)
    end as wcut_split
from (select distinct(updated_layer),well,prod_date,dayson,gross,oil,water,gas,wcut,net_thick,perm,net_thick * perm as kh from (select * from (select * from (select well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
where well = 'T-089'
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
where well = 'T-089'
order by prod_date asc, status_date desc)
where split_check = 1)
inner join (select prod_date as max_proddate,perforate_date as max_perfdate,top_perf as max_topperf,bot_perf as max_botperf,max(status_date) as max_statdate from
(select * from (select well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
where well = 'T-089'
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
where well = 'T-089'
order by prod_date asc, status_date desc)
where split_check = 1)
group by prod_date,perforate_date,top_perf,bot_perf)
on prod_date = max_proddate and perforate_date = max_perfdate and top_perf = max_topperf and bot_perf = max_botperf and status_date = max_statdate
order by prod_date asc,perforate_date asc)
where status = 'OPEN'
order by prod_date asc)
inner join (select well as well_kh, prod_date as proddate_kh, sum(kh) as kh_total from
(select distinct(updated_layer),well,prod_date,dayson,gross,oil,water,gas,wcut,net_thick,perm,net_thick * perm as kh from (select * from (select * from (select well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
inner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
where well = 'T-089'
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
where well = 'T-089'
order by prod_date asc, status_date desc)
where split_check = 1)
inner join (select prod_date as max_proddate,perforate_date as max_perfdate,top_perf as max_topperf,bot_perf as max_botperf,max(status_date) as max_statdate from
(select * from (select well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
where well = 'T-089'
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
where well = 'T-089'
order by prod_date asc, status_date desc)
where split_check = 1)
group by prod_date,perforate_date,top_perf,bot_perf)
on prod_date = max_proddate and perforate_date = max_perfdate and top_perf = max_topperf and bot_perf = max_botperf and status_date = max_statdate
order by prod_date asc,perforate_date asc)
where status = 'OPEN'
order by prod_date asc)
group by well,prod_date
order by prod_date)
on well = well_kh and prod_date = proddate_kh
order by prod_date asc;

/* Full Version */
select structure,well,updated_layer as layer,prod_date,dayson,round(kh/total_kh*gross,2) as gross_split,round(kh/total_kh*oil,2) as oil_split,round(kh/total_kh*water,2) as water_split,round(kh/total_kh*gas,2) as gas_split,
    case
        when gross = 0 Then Null
        else round(wcut,2)
    end as wcut_split
from (select distinct(updated_layer),structure,well,prod_date,dayson,gross,oil,water,gas,wcut,net_thick,perm,net_thick * perm as kh from (select * from (select * from (select structure,well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
order by prod_date asc, status_date desc)
where split_check = 1)
inner join (select well as max_well, prod_date as max_proddate,perforate_date as max_perfdate,top_perf as max_topperf,bot_perf as max_botperf,max(status_date) as max_statdate from
(select * from (select structure,well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
order by prod_date asc, status_date desc)
where split_check = 1)
group by well,prod_date,perforate_date,top_perf,bot_perf)
on well = max_well and prod_date = max_proddate and perforate_date = max_perfdate and top_perf = max_topperf and bot_perf = max_botperf and status_date = max_statdate
order by well asc,prod_date asc,perforate_date asc)
where status = 'OPEN')
inner join (select well as well_kh, prod_date as proddate_kh, sum(kh) as total_kh from
(select distinct(updated_layer),well,prod_date,dayson,gross,oil,water,gas,wcut,net_thick,perm,net_thick * perm as kh from (select * from (select * from (select structure,well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
order by prod_date asc, status_date desc)
where split_check = 1)
inner join (select well as max_well, prod_date as max_proddate,perforate_date as max_perfdate,top_perf as max_topperf,bot_perf as max_botperf,max(status_date) as max_statdate from
(select * from (select structure,well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
order by prod_date asc, status_date desc)
where split_check = 1)
group by well,prod_date,perforate_date,top_perf,bot_perf)
on well = max_well and prod_date = max_proddate and perforate_date = max_perfdate and top_perf = max_topperf and bot_perf = max_botperf and status_date = max_statdate
order by well asc,prod_date asc,perforate_date asc)
where status = 'OPEN')
group by well,prod_date
order by prod_date)
on well = well_kh and prod_date = proddate_kh
where 
well = 'T-089'
order by well asc, prod_date asc;

/* Selector Verified */
select well,updated_layer as layer,prod_date,dayson,round(kh/kh_total*gross,2) as gross_split,round(kh/kh_total*oil,2) as oil_split,round(kh/kh_total*water,2) as water_split,round(kh/kh_total*gas,2) as gas_split,
    case
        when gross = 0 Then Null
        else round(wcut,2)
    end as wcut_split
from (select distinct(updated_layer),well,prod_date,dayson,gross,oil,water,gas,wcut,net_thick,perm,net_thick * perm as kh from (select * from (select * from (select well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
inner join

(select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join 

(select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
where well = 'T-089'
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
where well = 'T-089'
order by prod_date asc, status_date desc)
where split_check = 1)
inner join 

(select prod_date as max_proddate,perforate_date as max_perfdate,top_perf as max_topperf,bot_perf as max_botperf,max(status_date) as max_statdate from
(select * from (select well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
inner join 

(select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join 

(select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
where well = 'T-089'
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
where well = 'T-089'
order by prod_date asc, status_date desc)
where split_check = 1)
group by prod_date,perforate_date,top_perf,bot_perf)
on prod_date = max_proddate and perforate_date = max_perfdate and top_perf = max_topperf and bot_perf = max_botperf and status_date = max_statdate
order by prod_date asc,perforate_date asc)
where status = 'OPEN'
order by prod_date asc)
inner join 

(select well as well_kh, prod_date as proddate_kh, sum(kh) as kh_total from
(select distinct(updated_layer),well,prod_date,dayson,gross,oil,water,gas,wcut,net_thick,perm,net_thick * perm as kh from (select * from (select * from (select well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
inner join 

(select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join 

(select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
where well = 'T-089'
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
where well = 'T-089'
order by prod_date asc, status_date desc)
where split_check = 1)
inner join 

(select prod_date as max_proddate,perforate_date as max_perfdate,top_perf as max_topperf,bot_perf as max_botperf,max(status_date) as max_statdate from
(select * from (select well,prod_date,dayson,gross,oil,water,gas,wcut,
    case
        when status_date <= prod_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_prodmth
inner join 

(select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join 

(select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
where well = 'T-089'
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
where well = 'T-089'
order by prod_date asc, status_date desc)
where split_check = 1)
group by prod_date,perforate_date,top_perf,bot_perf)
on prod_date = max_proddate and perforate_date = max_perfdate and top_perf = max_topperf and bot_perf = max_botperf and status_date = max_statdate
order by prod_date asc,perforate_date asc)
where status = 'OPEN'
order by prod_date asc)
group by well,prod_date
order by prod_date)
on well = well_kh and prod_date = proddate_kh
order by prod_date asc;

/* Split Monthly Inj */
select structure,well,updated_layer as layer,inj_date,dayson,round(kh/total_kh*winjvol,2) as winj_split, winjpr as WHP
from (select distinct(updated_layer),structure,well,inj_date,dayson,winjvol,winjpr,net_thick,perm,net_thick * perm as kh from (select * from (select * from (select structure,well,inj_date,dayson,winjvol,winjpr,
    case
        when status_date <= inj_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_injmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
order by inj_date asc, status_date desc)
where split_check = 1)
inner join (select well as max_well, inj_date as max_injdate,perforate_date as max_perfdate,top_perf as max_topperf,bot_perf as max_botperf,max(status_date) as max_statdate from
(select * from (select structure,well,inj_date,dayson,winjvol,winjpr,
    case
        when status_date <= inj_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_injmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
order by inj_date asc, status_date desc)
where split_check = 1)
group by well,inj_date,perforate_date,top_perf,bot_perf)
on well = max_well and inj_date = max_injdate and perforate_date = max_perfdate and top_perf = max_topperf and bot_perf = max_botperf and status_date = max_statdate
order by well asc,inj_date asc,perforate_date asc)
where status = 'OPEN')
inner join (select well as well_kh, inj_date as injdate_kh, sum(kh) as total_kh from
(select distinct(updated_layer),well,inj_date,dayson,winjvol,winjpr,net_thick,perm,net_thick * perm as kh from (select * from (select * from (select structure,well,inj_date,dayson,winjvol,winjpr,
    case
        when status_date <= inj_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_injmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
order by inj_date asc, status_date desc)
where split_check = 1)
inner join (select well as max_well, inj_date as max_injdate,perforate_date as max_perfdate,top_perf as max_topperf,bot_perf as max_botperf,max(status_date) as max_statdate from
(select * from (select structure,well,inj_date,dayson,winjvol,winjpr,
    case
        when status_date <= inj_date Then 1
        else 0
    end as split_check,
perforate_date,status_date,top_perf,bot_perf,perf_length,status,updated_layer,net_thick,perm,poro,sw from datamart.well_injmth
innner join (select well as well_split,perforate_date,status_date,top_perf,bot_perf,bot_perf - top_perf as perf_length,status,updated_layer,net_thick, perm, poro, sw from (select well, status_date, top_perf,bot_perf,status,perforate_date,
    case
        when top_perf < topmd and bot_perf < topmd Then 0
        when top_perf > botmd and bot_perf > botmd Then 0
        when top_perf >= topmd and bot_perf <= botmd Then 1
        when top_perf >= topmd and top_perf <= botmd and botmd - top_perf > 1 Then 1
        when top_perf < topmd and bot_perf > topmd and bot_perf <= botmd and bot_perf - topmd > 1 Then 1
        else -1
    end as layer_check,
topmd,botmd,updated_layer,net_thick, perm, poro, sw from (select well, status_date,top_perf,bot_perf,status,perforate_date,topmd,botmd,updated_layer,net_thick, perm, poro, sw from datamart.perforation_status
inner join (select well as well_prf, topmd, botmd, layer as updated_layer, net_thick, perm, poro, sw from datamart.well_properties)
on well = well_prf
order by top_perf asc, status asc))
where layer_check = 1
order by status_date asc, top_perf asc)
on well = well_split
order by inj_date asc, status_date desc)
where split_check = 1)
group by well,inj_date,perforate_date,top_perf,bot_perf)
on well = max_well and inj_date = max_injdate and perforate_date = max_perfdate and top_perf = max_topperf and bot_perf = max_botperf and status_date = max_statdate
order by well asc,inj_date asc,perforate_date asc)
where status = 'OPEN')
group by well,inj_date
order by inj_date)
on well = well_kh and inj_date = injdate_kh
where 
structure = 'Tanjung (WF/SecRec)'
order by well asc, inj_date asc;

select asset, area, datamart.well_proddaily_bot.structure, datamart.well_proddaily_bot.well,prod_date,gross,oil,water,wcut,gas,gross_oil_rate,net_oil_rate,wcut from datamart.well_proddaily_bot
full outer join datamart.well_test
on datamart.well_proddaily_bot.well = datamart.well_test.well and prod_date = test_date
where datamart.well_proddaily_bot.well = 'L5A-286ST'
order by prod_date desc;

select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate
from datamart.well_off
where well = 'L5A-286ST'
order by off_date desc;

/* Checkpoint 1 */
select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0            
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gas,
off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and current_date - date_off - 1 > 1 Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
        --when prod_date = date_off or prod_date = date_off or prod_date between date_off and date_on Then 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate
from datamart.well_off
order by off_date desc)
on well = well_off)
where well = 'L5A-286ST'
order by prod_date asc;

/* off_check = 1 */
select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0            
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gas,
off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and current_date - date_off - 1 > 1 Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
        --when prod_date = date_off or prod_date = date_off or prod_date between date_off and date_on Then 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate
from datamart.well_off
order by off_date desc)
on well = well_off)
where off_check = 1)
where well = 'L5A-286ST'
order by prod_date asc;

/* off_check = 0 */
select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas from (select distinct(prod_date) as prod_date,structure,well,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0            
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gas,
off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and current_date - date_off - 1 > 1 Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
        --when prod_date = date_off or prod_date = date_off or prod_date between date_off and date_on Then 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate
from datamart.well_off
order by off_date desc)
on well = well_off)
where off_check = 0))
where well = 'L5A-286ST'
order by prod_date asc;

/* Eliminated 0 From 1 */
select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,well_one from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas from (select distinct(prod_date) as prod_date,structure,well,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0            
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gas,
off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and current_date - date_off - 1 > 1 Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
        --when prod_date = date_off or prod_date = date_off or prod_date between date_off and date_on Then 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate
from datamart.well_off
order by off_date desc)
on well = well_off)
where off_check = 0)))
full outer join (select well as well_one,prod_date as prod_date_one from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0            
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gas,
off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and current_date - date_off - 1 > 1 Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
        --when prod_date = date_off or prod_date = date_off or prod_date between date_off and date_on Then 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate
from datamart.well_off
order by off_date desc)
on well = well_off)
where off_check = 1))
on well = well_one and prod_date = prod_date_one)
where well_one is null and 
well = 'L5A-286ST'
order by prod_date asc;

/* Union */
select * from (select * from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0            
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gas,
off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and current_date - date_off - 1 > 1 Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
        --when prod_date = date_off or prod_date = date_off or prod_date between date_off and date_on Then 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate
from datamart.well_off
order by off_date desc)
on well = well_off)
where off_check = 1))

Union

select * from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,well_one from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas from (select distinct(prod_date) as prod_date,structure,well,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0            
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gas,
off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and current_date - date_off - 1 > 1 Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
        --when prod_date = date_off or prod_date = date_off or prod_date between date_off and date_on Then 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate
from datamart.well_off
order by off_date desc)
on well = well_off)
where off_check = 0)))
full outer join (select well as well_one,prod_date as prod_date_one from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0            
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gas,
off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and current_date - date_off - 1 > 1 Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
        --when prod_date = date_off or prod_date = date_off or prod_date between date_off and date_on Then 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate
from datamart.well_off
order by off_date desc)
on well = well_off)
where off_check = 1))
on well = well_one and prod_date = prod_date_one)
where well_one is null))
where well = 'L5A-286ST'
order by prod_date asc;

/* Bug Fixed */
select * from (select * from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0            
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gas,
off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 1))

Union

select * from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,well_one from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas from (select distinct(prod_date) as prod_date,structure,well,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0            
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gas,
off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 0)))
full outer join (select well as well_one,prod_date as prod_date_one from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0            
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                end
          end,2) as tcbd_gas,
off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 1))
on well = well_one and prod_date = prod_date_one)
where well_one is null))
where well = 'L5A-286ST'
order by prod_date asc;

/* With Asset,Area */
select asset,area,structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason as down_reason from (select * from (select * from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 1))

Union

select * from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason as down_reason from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason,well_one from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select distinct(prod_date) as prod_date,structure,well,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 0)))
full outer join (select well as well_one,prod_date as prod_date_one from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 1))
on well = well_one and prod_date = prod_date_one)
where well_one is null)))
inner join (select asset,area,well as well_pair from datamart.well_last_data)
on well = well_pair where 
structure = 'Niru'
and prod_date between
'20-06-2020'
and
'30-06-2020'
order by asset asc,area asc,structure asc,prod_date asc,well asc;

select well,prod_date,gross from datamart.well_proddaily_bot
where well in ('L5A-253','L5A-195','L5A-227','L5A-187')
order by prod_date desc;

select well,off_date,on_date from datamart.well_off
where well in ('L5A-253','L5A-195','L5A-227','L5A-187')
order by off_date desc;

select asset,area,structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason as down_reason from (select * from (select * from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 1))

Union

select * from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason as down_reason from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason,well_one from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select distinct(prod_date) as prod_date,structure,well,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 0)))
full outer join (select well as well_one,prod_date as prod_date_one from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 1))
on well = well_one and prod_date = prod_date_one)
where well_one is null)))
inner join (select asset,area,well as well_pair from datamart.well_last_data)
on well = well_pair where structure = 'Niru' and prod_date between to_date('20-06-2020', 'DD-MM-YYYY') and to_date('30-06-2020', 'DD-MM-YYYY') order by asset asc,area asc,structure asc,prod_date asc,well asc;

select asset,area,structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason as down_reason from (select * from (select * from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 1))

Union

select * from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason as down_reason from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason,well_one from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select distinct(prod_date) as prod_date,structure,well,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 0)))
full outer join (select well as well_one,prod_date as prod_date_one from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 1))
on well = well_one and prod_date = prod_date_one)
where well_one is null)))
inner join (select asset,area,well as well_pair from datamart.well_last_data)
on well = well_pair where structure = 'Niru' and prod_date between to_date('20-06-2020', 'DD-MM-YYYY') and to_date('30-06-2020', 'DD-MM-YYYY') order by asset asc,area asc,structure asc,prod_date asc,well asc;

select asset,area,structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason as down_reason from (select * from (select * from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 1))

Union

select * from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason as down_reason from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason,well_one from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select distinct(prod_date) as prod_date,structure,well,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 0)))
full outer join (select well as well_one,prod_date as prod_date_one from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 1))
on well = well_one and prod_date = prod_date_one)
where well_one is null)))
inner join (select asset,area,well as well_pair from datamart.well_last_data)
on well = well_pair where structure = 'Niru' and prod_date between to_date('20-06-2020', 'DD-MM-YYYY') and to_date('30-06-2020', 'DD-MM-YYYY') order by asset asc,area asc,structure asc,prod_date asc,well asc;

select * from (select * from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,cast(to_char(off_date,'DD-MM-YYYY') as date) as date_off,cast(to_char(on_date,'DD-MM-YYYY') as date) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 1))

Union

select * from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason as down_reason from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason,well_one from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select distinct(prod_date) as prod_date,structure,well,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,cast(to_char(off_date,'DD-MM-YYYY') as date) as date_off,cast(to_char(on_date,'DD-MM-YYYY') as date) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 0)))
full outer join (select well as well_one,prod_date as prod_date_one from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,cast(to_char(off_date,'DD-MM-YYYY') as date) as date_off,cast(to_char(on_date,'DD-MM-YYYY') as date) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 1))
on well = well_one and prod_date = prod_date_one)
where well_one is null))
where structure = 'Niru' and prod_date between to_date('20-06-2020', 'DD-MM-YYYY') and to_date('30-06-2020', 'DD-MM-YYYY') order by structure asc,prod_date asc,well asc;

select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 1)
where structure = 'Niru' and prod_date between to_date('20-06-2020', 'DD-MM-YYYY') and to_date('30-06-2020', 'DD-MM-YYYY') order by structure asc,prod_date asc,well asc;

select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off
where structure = 'Niru' and prod_date between to_date('20-06-2020', 'DD-MM-YYYY') and to_date('30-06-2020', 'DD-MM-YYYY') order by structure asc,prod_date asc,well asc;

select well as well_off,to_date(to_char(off_date,'DD-MM-YYYY')) as date_off,to_date(to_char(on_date,'DD-MM-YYYY')) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
where structure = 'Niru'
order by off_date desc;

select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
where structure = 'Niru'
group by well;

select well as well_off,
cast(to_char(off_date,'DD-MM-YYYY') as date) as date_off,cast(to_char(on_date,'DD-MM-YYYY') as date) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason
from datamart.well_off
where structure = 'Niru';

select well as well_off,
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason
from datamart.well_off
where structure = 'Niru';

/* Fix Final */
select asset,area,structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason as down_reason from (select * from (select * from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,cast(to_char(off_date,'DD-MM-YYYY') as date) as date_off,cast(to_char(on_date,'DD-MM-YYYY') as date) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 1))

Union

select * from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason as down_reason from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason,well_one from (select structure,well,prod_date,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select distinct(prod_date) as prod_date,structure,well,prod_hrs,tcbd_gross,tcbd_oil,tcbd_water,tcbd_wc,tcbd_gas,reason from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,cast(to_char(off_date,'DD-MM-YYYY') as date) as date_off,cast(to_char(on_date,'DD-MM-YYYY') as date) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 0)))
full outer join (select well as well_one,prod_date as prod_date_one from (select structure,well,prod_date,
    case
        when off_check = 0 Then 24
        else
            case
                when prod_date = date_off Then prodhrs_offdate
                when prod_date = date_on Then prodhrs_ondate
                when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                else 0
            end
    end as prod_hrs,
    round(case
            when off_check = 0 Then gross
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gross
                    when prod_date = date_on Then prodhrs_ondate/24*gross
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gross,
    round(case
            when off_check = 0 Then oil
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*oil
                    when prod_date = date_on Then prodhrs_ondate/24*oil
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_oil,
    round(case
            when off_check = 0 Then water
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*water
                    when prod_date = date_on Then prodhrs_ondate/24*water
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_water,
    case
        when off_check = 0 Then wcut
        else
        case
            when prod_date = date_off Then
                case
                    when prodhrs_offdate = 0 Then Null
                    else wcut
                end
            when prod_date = date_on Then
                case
                    when prodhrs_ondate = 0 Then Null
                    else wcut
                end
            when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then Null
            else Null
        end
    end as tcbd_wc,
    round(case
            when off_check = 0 Then gas
            else
                case
                    when prod_date = date_off Then prodhrs_offdate/24*gas
                    when prod_date = date_on Then prodhrs_ondate/24*gas
                    when prod_date > date_off and prod_date < date_on and prod_date between date_off and date_on Then 0
                    else 0
                end
          end,2) as tcbd_gas,
reason,off_check from (select structure,well,prod_date,gross,oil,water,wcut,gas,
    case
        when prod_date > date_off and date_on is Null and date_off != max_offdate Then 0
        when prod_date < date_off Then 0
        when prod_date > date_on Then 0
        else 1
    end as off_check,
date_off,date_on,prodhrs_offdate,prodhrs_ondate,reason from datamart.well_proddaily_bot
inner join (select well as well_off,cast(to_char(off_date,'DD-MM-YYYY') as date) as date_off,cast(to_char(on_date,'DD-MM-YYYY') as date) as date_on, 
(extract(hour from off_date) + extract(minute from off_date)/60 + extract(second from off_date)/3600) as prodhrs_offdate,
24 - (extract(hour from on_date) + extract(minute from on_date)/60 + extract(second from on_date)/3600) as prodhrs_ondate,reason,to_date(to_char(max_offdate,'DD-MM-YYYY')) as max_offdate
from datamart.well_off
inner join (select well as max_welloff,max(off_date) as max_offdate from datamart.well_off
group by well)
on well = max_welloff
order by off_date desc)
on well = well_off)
where off_check = 1))
on well = well_one and prod_date = prod_date_one)
where well_one is null)))
inner join (select asset,area,well as well_pair from datamart.well_last_data)
on well = well_pair where 
structure = 'Niru'
and prod_date between cast('20-06-2020' as date) and cast('30-06-2020' as date)
--'20-06-2020'
--and
--'30-06-2020'
order by asset asc,area asc,structure asc,prod_date asc,well asc;