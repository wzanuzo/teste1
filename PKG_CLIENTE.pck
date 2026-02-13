CREATE OR REPLACE PACKAGE PKG_CLIENTE IS

TYPE REC_CLIENTES is RECORD(
  id_cliente tb_cliente.id_cliente%type,
  nome tb_cliente.nome%type,
  email tb_cliente.email%type,
  cep tb_cliente.cep%type,
  logradouro tb_cliente.logradouro%type,
  bairro tb_cliente.bairro%type,
  uf tb_cliente.uf%type,
  ativo tb_cliente.ativo%type,
  dt_criacao tb_cliente.dt_criacao%type ,
  dt_atualizacao tb_cliente.dt_atualizacao%type);

  TYPE TAB_CLIENTES is table of REC_CLIENTES INDEX BY BINARY_INTEGER;

  FUNCTION FN_VALIDAR_EMAIL(p_email VARCHAR2) RETURN NUMBER;
  FUNCTION FN_NORMALIZAR_CEP(p_cep VARCHAR2) RETURN VARCHAR2;
  PROCEDURE PRC_DELETAR_CLIENTE(p_id NUMBER);
  PROCEDURE PRC_LISTAR_CLIENTES(p_nome VARCHAR2, p_email VARCHAR2, p_rc OUT TAB_CLIENTES);
  
  PROCEDURE PRC_INSERIR_CLIENTE(p_id_cliente OUT NUMBER,
                                p_nome tb_cliente.nome%type,
                                p_email tb_cliente.email%type,
                                p_cep tb_cliente.cep%type,
                                p_logradouro tb_cliente.logradouro%type,
                                p_bairro tb_cliente.bairro%type,
                                p_uf tb_cliente.uf%type
                                );
  
  
END;
/
CREATE OR REPLACE PACKAGE BODY PKG_CLIENTE IS
  FUNCTION FN_VALIDAR_EMAIL(p_email VARCHAR2) RETURN NUMBER IS
    vnRetorno number;
  BEGIN
    IF owa_pattern.match(p_email,'^\w{1,}[.,0-9,a-z,A-Z,_,-]\w{1,}[.,0-9,a-z,A-Z,_-]\w{1,}'||
                                   '@\w{1,}[.,0-9,a-z,A-Z,_]\w{1,}[.,0-9,a-z,A-Z,_]\w{1,}[.,0-9,a-z,A-Z,_]\w{1,}$') THEN
      vnRetorno:=1;
    ELSE
      vnRetorno:=0;
    END IF;    
    RETURN vnRetorno;
  END;
  /**********************************************/
  FUNCTION FN_NORMALIZAR_CEP(p_cep VARCHAR2) RETURN VARCHAR2 IS 
    vcCep VARCHAR2(8);
  BEGIN
    SELECT REGEXP_REPLACE(p_cep, '[^0-9]', '') 
    INTO vcCep 
    FROM DUAL;
    return vcCep;
  END;
  /**********************************************/
  PROCEDURE PRC_DELETAR_CLIENTE(p_id NUMBER) IS
  BEGIN
    delete from tb_cliente WHERE id_cliente = p_id;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20002,SQLERRM);  
  END;   
  /**********************************************/  
  PROCEDURE PRC_LISTAR_CLIENTES(p_nome VARCHAR2, p_email VARCHAR2, p_rc OUT TAB_CLIENTES) IS
  BEGIN
    SELECT t.id_cliente,
           t.nome,
           t.email,
           t.cep,
           t.logradouro,
           t.bairro,
           t.uf,
           t.ativo,
           t.dt_criacao,
           t.dt_atualizacao 
    BULK COLLECT
    INTO p_rc
    FROM TB_CLIENTE t 
    WHERE t.nome like p_nome||'%' OR t.email like p_email||'%';
    
  END;
  /**********************************************/     
  PROCEDURE PRC_INSERIR_CLIENTE(p_id_cliente OUT NUMBER,
                                p_nome tb_cliente.nome%type,
                                p_email tb_cliente.email%type,
                                p_cep tb_cliente.cep%type,
                                p_logradouro tb_cliente.logradouro%type,
                                p_bairro tb_cliente.bairro%type,
                                p_uf tb_cliente.uf%type
                                ) IS 

  BEGIN
    IF p_nome IS NULL THEN
       raise_application_error(-20001,'Nome Obrigatorio');  
    END IF;
    
    IF pkg_cliente.FN_VALIDAR_EMAIL(p_email) = 0  THEN
       raise_application_error(-20001,'Email inválido');  
    END IF;

    IF length(pkg_cliente.FN_NORMALIZAR_CEP(p_cep)) <> 8  THEN
       raise_application_error(-20001,'Cep inválido');  
    END IF;    
        
    p_id_cliente := seq_cliente.nextval;
    BEGIN
      INSERT INTO tb_cliente(id_cliente,
                             nome,
                             email,
                             cep,
                             logradouro,
                             bairro,
                             uf,
                             ativo,
                             dt_criacao)
                        VALUES(p_id_cliente
                               ,p_nome
                               ,p_email
                               ,pkg_cliente.FN_NORMALIZAR_CEP(p_cep)
                               ,p_logradouro
                               ,p_bairro
                               ,p_uf
                               ,1
                               ,sysdate
                               );
    EXCEPTION 
      WHEN DUP_VAL_ON_INDEX THEN
        raise_application_error(-20002,'Email já existente');       
      WHEN OTHERS THEN
        IF SQLCODE = -2290 THEN
          raise_application_error(-20002,'UF inválido');       
        ELSE
           raise_application_error(-20002,'UF inválido');       
       END IF;            
    END;
  END;                                 
END;
/
