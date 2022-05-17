create table instore(cust_id number,
cust_name varchar(20),
city varchar(20),
store_name varchar(20));


INSERT INTO INSTORE (CUST_ID, CUST_NAME, CITY, STORE_NAME) VALUES (1, 'TIM','BANGALORE', 'COSTA COFEE');
INSERT INTO INSTORE (CUST_ID, CUST_NAME, CITY, STORE_NAME) VALUES (2, 'BIM','MANGALORE', 'BIG BAZAR');
INSERT INTO INSTORE (CUST_ID, CUST_NAME, CITY, STORE_NAME) VALUES (3, 'RICK', 'TEXAS','MORE');
INSERT INTO INSTORE (CUST_ID, CUST_NAME, CITY, STORE_NAME) VALUES (4, 'SMITH','LONDON','SHOPER STOP');

create table web_cust(cust_id number,
cust_name varchar(20),
cust_city varchar(20),
email varchar(30),
status varchar(20));


INSERT INTO WEB_CUST (CUST_ID, CUST_NAME, CUST_CITY, EMAIL, STATUS) VALUES (11,'RAM','KOLAR','RAM@GMAIL.COM','BOUNCED');
INSERT INTO WEB_CUST (CUST_ID, CUST_NAME, CUST_CITY, STATUS) VALUES (12, 'SHAM','MYSORE','COMPLETED');
INSERT INTO WEB_CUST (CUST_ID, CUST_NAME, CUST_CITY, EMAIL, STATUS) VALUES (13,'SMITHA', 'TEXAS', 'SMITHA@GMAIL.COM', 'COMPLETED');
INSERT INTO WEB_CUST (CUST_ID, CUST_NAME, CUST_CITY, EMAIL, STATUS) VALUES (14,'SMITH', 'LONDON', 'SMITH@YAHOO.COM', 'PROCESSED');
INSERT INTO WEB_CUST (CUST_ID, CUST_NAME, CUST_CITY, EMAIL, STATUS) VALUES (15,'TIM', 'BANGALORE', 'TIM@YAHOO.COM', 'PROCESSED');

create table call_center_cust(cust_id number,
cust_name varchar(20),
city varchar(20),
rep_name varchar(20),
phone number);

INSERT INTO CALL_CENTER_CUST (CUST_ID, CUST_NAME, CITY, REP_NAME, PHONE) VALUES
(21, 'RAM', 'KOLAR', 'RAJESH', 8876543345);
INSERT INTO CALL_CENTER_CUST (CUST_ID, CUST_NAME, CITY, REP_NAME, PHONE) VALUES
(22, 'TIM', 'BANGALORE', 'RAMESH', 2323245678);

INSERT INTO CALL_CENTER_CUST (CUST_ID, CUST_NAME, CITY, REP_NAME) VALUES (23,
'MICK', 'TEXAS', 'NASREEN');
INSERT INTO CALL_CENTER_CUST (CUST_ID, CUST_NAME, CITY, REP_NAME, PHONE) VALUES
(24, 'DAVID', 'MAGALORE', 'THRUPA', 4576988999);

CREATE TABLE TARGET_TABLE_CUST_DIM(cust_id number,
cust_name varchar(20),
city varchar(20),
email varchar(30),
phone number,
rep_name varchar(20),
SRC_CUST_ID NUMBER,SOURCE VARCHAR(20));

CREATE TABLE REJECT_CUST_TABLE(REJ_ID NUMBER,
SRC_REC VARCHAR(20),
REASON VARCHAR(100));

commit;
------------------------------------------------------------
select * from instore;
select * from web_cust;
select * from CALL_CENTER_CUST;
select * from TARGET_TABLE_CUST_DIM;
select * from REJECT_CUST_TABLE;
desc TARGET_TABLE_CUST_DIM;
/
create sequence seq_rej_id;
create sequence seq_cust_id;
/
create or replace procedure sp_store
as
    cursor cur_store is select * from instore;
    cursor cur_call is select * from call_center_cust;
    CURSOR CUR_WEB is select * from web_cust;
    v_cnt number;
    v_cnt1 number;
    v_cnt2 number;
begin
    for i in cur_store loop
        select count(*) into v_cnt
        from instore
        where cust_name=i.cust_name
        and city=i.city;
        if i.store_name is null then
            insert into REJECT_CUST_TABLE values(seq_rej_id.nextval,'store','store name is null');
        else
            insert into TARGET_TABLE_CUST_DIM (cust_id,cust_name,city,src_cust_id,source) values (seq_cust_id.nextval,i.cust_name,i.city,i.cust_id,'instore');
        end if;
    end loop;
    for j in cur_call loop
        select count(*) into v_cnt1
        from call_center_cust
        where cust_name=i.cust_name
        and city=i.city;
        if j.phone is null or j.rep_name is null then
            insert into REJECT_CUST_TABLE values(seq_rej_id.nextval,'call_center','No phone number or rep_name');
        else
             insert into TARGET_TABLE_CUST_DIM (cust_id,cust_name,city,phone,rep_name,src_cust_id,source) values (seq_cust_id.nextval,j.cust_name,j.city,j.phone,j.rep_name,j.cust_id,'call_center');
        end if;
    end loop;
    for k in cur_web loop
        if k.email is null or (k.email not like '%@%') or (k.status='BOUNCED') then
            insert into REJECT_CUST_TABLE values(seq_rej_id.nextval,'web','no email or status is bounced');
        else
            insert into TARGET_TABLE_CUST_DIM (cust_id,cust_name,city,email,src_cust_id,source) values (seq_cust_id.nextval,k.cust_name,k.cust_city,k.email,k.cust_id,'web_cust');
        end if;
    end loop;
end;
/
exec sp_store;
/
truncate table TARGET_TABLE_CUST_DIM ;
truncate table REJECT_CUST_TABLE;
/
select *
from instore s,web_cust w,CALL_CENTER_CUST c
where 
/