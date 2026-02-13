-- Create table
create table TB_CLIENTE
(
  id_cliente     NUMBER not null,
  nome           VARCHAR2(100) not null,
  email          VARCHAR2(100),
  cep            VARCHAR2(8),
  logradouro     VARCHAR2(200),
  bairro         VARCHAR2(60),
  uf             VARCHAR2(2),
  ativo          NUMBER default 1,
  dt_criacao     DATE default sysdate,
  dt_atualizacao DATE
);

alter table TB_CLIENTE
  add constraint TB_CLIENTE_PK primary key (ID_CLIENTE);
  
alter table TB_CLIENTE
  add constraint TB_CLIENTE_UK01 unique (EMAIL);

alter table TB_CLIENTE
  add constraint TB_CLIENTE_UF
  check (UF IN ('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP','SE','TO'));

create sequence SEQ_CLIENTE
minvalue 1
maxvalue 9999999
start with 1
increment by 1;


CREATE OR REPLACE TRIGGER TRG_CLIENTE_BI BEFORE INSERT ON TB_CLIENTE
FOR EACH ROW
BEGIN
  :NEW.ID_CLIENTE := SEQ_CLIENTE.NEXTVAL;
  :NEW.DT_CRIACAO := sysdate;
END;
