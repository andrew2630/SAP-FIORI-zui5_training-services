*---------------------------------------------------------------------*
*    view related FORM routines
*   generation date: 11.02.2022 at 19:08:51
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZAPV_SUPPLIERS..................................*
FORM GET_DATA_ZAPV_SUPPLIERS.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZAP_SUPPLIERS WHERE
(VIM_WHERETAB) .
    CLEAR ZAPV_SUPPLIERS .
ZAPV_SUPPLIERS-MANDT =
ZAP_SUPPLIERS-MANDT .
ZAPV_SUPPLIERS-SUPPLIER_ID =
ZAP_SUPPLIERS-SUPPLIER_ID .
ZAPV_SUPPLIERS-COMPANY_NAME =
ZAP_SUPPLIERS-COMPANY_NAME .
ZAPV_SUPPLIERS-ADDRESS =
ZAP_SUPPLIERS-ADDRESS .
ZAPV_SUPPLIERS-CITY =
ZAP_SUPPLIERS-CITY .
ZAPV_SUPPLIERS-COUNTRY =
ZAP_SUPPLIERS-COUNTRY .
<VIM_TOTAL_STRUC> = ZAPV_SUPPLIERS.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZAPV_SUPPLIERS .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZAPV_SUPPLIERS.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZAPV_SUPPLIERS-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZAP_SUPPLIERS WHERE
  SUPPLIER_ID = ZAPV_SUPPLIERS-SUPPLIER_ID .
    IF SY-SUBRC = 0.
    DELETE ZAP_SUPPLIERS .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZAP_SUPPLIERS WHERE
  SUPPLIER_ID = ZAPV_SUPPLIERS-SUPPLIER_ID .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZAP_SUPPLIERS.
    ENDIF.
ZAP_SUPPLIERS-MANDT =
ZAPV_SUPPLIERS-MANDT .
ZAP_SUPPLIERS-SUPPLIER_ID =
ZAPV_SUPPLIERS-SUPPLIER_ID .
ZAP_SUPPLIERS-COMPANY_NAME =
ZAPV_SUPPLIERS-COMPANY_NAME .
ZAP_SUPPLIERS-ADDRESS =
ZAPV_SUPPLIERS-ADDRESS .
ZAP_SUPPLIERS-CITY =
ZAPV_SUPPLIERS-CITY .
ZAP_SUPPLIERS-COUNTRY =
ZAPV_SUPPLIERS-COUNTRY .
    IF SY-SUBRC = 0.
    UPDATE ZAP_SUPPLIERS .
    ELSE.
    INSERT ZAP_SUPPLIERS .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZAPV_SUPPLIERS-UPD_FLAG,
STATUS_ZAPV_SUPPLIERS-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZAPV_SUPPLIERS.
  SELECT SINGLE * FROM ZAP_SUPPLIERS WHERE
SUPPLIER_ID = ZAPV_SUPPLIERS-SUPPLIER_ID .
ZAPV_SUPPLIERS-MANDT =
ZAP_SUPPLIERS-MANDT .
ZAPV_SUPPLIERS-SUPPLIER_ID =
ZAP_SUPPLIERS-SUPPLIER_ID .
ZAPV_SUPPLIERS-COMPANY_NAME =
ZAP_SUPPLIERS-COMPANY_NAME .
ZAPV_SUPPLIERS-ADDRESS =
ZAP_SUPPLIERS-ADDRESS .
ZAPV_SUPPLIERS-CITY =
ZAP_SUPPLIERS-CITY .
ZAPV_SUPPLIERS-COUNTRY =
ZAP_SUPPLIERS-COUNTRY .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZAPV_SUPPLIERS USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZAPV_SUPPLIERS-SUPPLIER_ID TO
ZAP_SUPPLIERS-SUPPLIER_ID .
MOVE ZAPV_SUPPLIERS-MANDT TO
ZAP_SUPPLIERS-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZAP_SUPPLIERS'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZAP_SUPPLIERS TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZAP_SUPPLIERS'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
