*&---------------------------------------------------------------------*
*& Report zqpg_source_code
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zqpg_source_code.

INCLUDE zqpg_questions_and_answers.

**********************************************************************

CLASS lcx_error DEFINITION INHERITING FROM cx_static_check FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor.

  PRIVATE SECTION.

ENDCLASS.

**********************************************************************

CLASS lcx_error IMPLEMENTATION.

  METHOD constructor.
    super->constructor(
*      EXPORTING
*        textid   =
*        previous =
    ).
  ENDMETHOD.

ENDCLASS.

**********************************************************************

CLASS lcl_screenshot DEFINITION FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor.

    METHODS make_screenshot_and_save
      RAISING
        lcx_error.

  PRIVATE SECTION.
    METHODS make_screenshot
      RETURNING
        VALUE(rv_result) TYPE xstring
      RAISING
        lcx_error.

    METHODS save_screenshot
      IMPORTING
        iv_screenshot TYPE xstring
      RAISING
        lcx_error.

    METHODS choose_directory_and_filename
      RETURNING
        VALUE(rv_result) TYPE string
      RAISING
        lcx_error.

    METHODS save_screenshot_by_fullpath
      IMPORTING
        iv_screenshot TYPE xstring
        iv_fullpath   TYPE string
      RAISING
        lcx_error.

    METHODS get_desktop_directory
      RETURNING
        VALUE(rv_result) TYPE string
      RAISING
        lcx_error.

ENDCLASS.

**********************************************************************

CLASS lcl_screenshot IMPLEMENTATION.

  METHOD constructor.
  ENDMETHOD.

  METHOD make_screenshot_and_save.
    DATA(lv_screenshot) = make_screenshot( ).
    IF lv_screenshot IS INITIAL.
      RETURN.
    ENDIF.

    save_screenshot( lv_screenshot ).
  ENDMETHOD.

  METHOD make_screenshot.
    DATA lv_mime_type TYPE string.

    cl_gui_frontend_services=>get_screenshot(
                                 IMPORTING
                                   mime_type_str        = lv_mime_type
                                   image                = rv_result
                                 EXCEPTIONS
                                   access_denied        = 1
                                   cntl_error           = 2
                                   error_no_gui         = 3
                                   not_supported_by_gui = 4
                                   OTHERS               = 5 ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW lcx_error( ).
    ENDIF.
  ENDMETHOD.

  METHOD save_screenshot.
    DATA(lv_fullpath) = choose_directory_and_filename( ).
    save_screenshot_by_fullpath( iv_screenshot = iv_screenshot
                                 iv_fullpath = lv_fullpath ).
  ENDMETHOD.

  METHOD choose_directory_and_filename.
    DATA lv_user_action TYPE i.
    DATA lv_filename TYPE string.
    DATA lv_fullpath TYPE string.
    DATA lv_path TYPE string.

    " finde Desktop-Verzeichnis

    "(*.png)|*.png|'

    cl_gui_frontend_services=>file_save_dialog(
      EXPORTING
        window_title              = 'Save your artwork'
        default_extension         = 'png'
        default_file_name         = 'abap_quiz_and_paint_result.png'
*       with_encoding             =
        file_filter               = '*.png'
        initial_directory         = get_desktop_directory( )
*       prompt_on_overwrite       = 'X'
      CHANGING
        filename                  = lv_filename
        path                      = lv_path
        fullpath                  = lv_fullpath
        user_action               = lv_user_action
*       file_encoding             =
      EXCEPTIONS
        cntl_error                = 1
        error_no_gui              = 2
        not_supported_by_gui      = 3
        invalid_default_file_name = 4
        OTHERS                    = 5 ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW lcx_error( ).
    ENDIF.

    IF lv_user_action <> cl_gui_frontend_services=>action_ok.
      RETURN.
    ENDIF.

    rv_result = lv_fullpath.
  ENDMETHOD.

  METHOD save_screenshot_by_fullpath.
    DATA(lt_raw_data) = cl_bcs_convert=>xstring_to_solix( iv_screenshot ).

    cl_gui_frontend_services=>gui_download(
      EXPORTING
        bin_filesize              = xstrlen( iv_screenshot )
        filename                  = iv_fullpath
        filetype                  = 'BIN'
*       append                    = SPACE
*       write_field_separator     = SPACE
*       header                    = '00'
*       trunc_trailing_blanks     = SPACE
*       write_lf                  = 'X'
*       col_select                = SPACE
*       col_select_mask           = SPACE
*       dat_mode                  = SPACE
*       confirm_overwrite         = SPACE
*       no_auth_check             = SPACE
*       codepage                  =
*       ignore_cerr               = ABAP_TRUE
*       replacement               = '#'
*       write_bom                 = SPACE
*       trunc_trailing_blanks_eol = 'X'
*       wk1_n_format              = SPACE
*       wk1_n_size                = SPACE
*       wk1_t_format              = SPACE
*       wk1_t_size                = SPACE
*       show_transfer_status      = 'X'
*       fieldnames                =
*       write_lf_after_last_line  = 'X'
*       virus_scan_profile        = '/SCET/GUI_DOWNLOAD'
*     IMPORTING
*       filelength                =
      CHANGING
        data_tab                  =  lt_raw_data
      EXCEPTIONS
        file_write_error          = 1
        no_batch                  = 2
        gui_refuse_filetransfer   = 3
        invalid_type              = 4
        no_authority              = 5
        unknown_error             = 6
        header_not_allowed        = 7
        separator_not_allowed     = 8
        filesize_not_allowed      = 9
        header_too_long           = 10
        dp_error_create           = 11
        dp_error_send             = 12
        dp_error_write            = 13
        unknown_dp_error          = 14
        access_denied             = 15
        dp_out_of_memory          = 16
        disk_full                 = 17
        dp_timeout                = 18
        file_not_found            = 19
        dataprovider_exception    = 20
        control_flush_error       = 21
        not_supported_by_gui      = 22
        error_no_gui              = 23
        OTHERS                    = 24 ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW lcx_error( ).
    ENDIF.
  ENDMETHOD.

  METHOD get_desktop_directory.
    DATA lv_desktop_dir_path TYPE string.

    " documentation says not to use this method, but
    " let's see how far we can go
    cl_gui_frontend_services=>get_desktop_directory(
      CHANGING
        desktop_directory    = lv_desktop_dir_path
      EXCEPTIONS
        cntl_error           = 1
        error_no_gui         = 2
        not_supported_by_gui = 3
        OTHERS               = 4 ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW lcx_error( ).
    ENDIF.

    cl_gui_cfw=>flush(
      EXCEPTIONS
        cntl_system_error = 1
        cntl_error        = 2
        OTHERS            = 3 ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW lcx_error( ).
    ENDIF.

    rv_result = lv_desktop_dir_path.
  ENDMETHOD.

ENDCLASS.

**********************************************************************

"! The class provides questions. Please note that a questions means the
"! question itself, three possible answers and the number of the right
"! answer.
CLASS lcl_questions DEFINITION FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_question,
             question     TYPE string,
             answer_1     TYPE string,
             answer_2     TYPE string,
             answer_3     TYPE string,
             right_answer TYPE i,
           END OF ty_question.

    TYPES ty_questions TYPE TABLE OF ty_question WITH EMPTY KEY.

    METHODS constructor.

    METHODS get_random_question
      RETURNING
        VALUE(rs_result) TYPE ty_question.

  PRIVATE SECTION.
    CONSTANTS mc_question_marker TYPE string VALUE '###'.

    TYPES ty_include_lines TYPE TABLE OF string WITH EMPTY KEY.

    TYPES: BEGIN OF ty_number_memory_entry,
             number TYPE i,
           END OF ty_number_memory_entry.

    TYPES ty_number_memory TYPE TABLE OF ty_number_memory_entry WITH EMPTY KEY.

    DATA mt_include_lines TYPE ty_include_lines.
    DATA mt_question_index TYPE match_result_tab.
    DATA mt_number_memory TYPE ty_number_memory.

    METHODS read_include_content
      IMPORTING
        iv_include_name  TYPE programm
      RETURNING
        VALUE(rt_result) TYPE ty_include_lines.

    METHODS get_start_line_of_question
      IMPORTING
        iv_question_number TYPE i
      RETURNING
        VALUE(rv_result)   TYPE i.

    METHODS get_end_line_of_question
      IMPORTING
        iv_start_line    TYPE i
      RETURNING
        VALUE(rv_result) TYPE i.

    METHODS get_question_by_number
      IMPORTING
        iv_question_number TYPE i
      RETURNING
        VALUE(rt_result)   TYPE string_table.

    METHODS build_question_index.

    METHODS get_lines_of_question
      IMPORTING
        iv_start_line    TYPE i
        iv_end_line      TYPE i
      RETURNING
        VALUE(rt_result) TYPE string_table.

    METHODS get_random_question_number
      RETURNING
        VALUE(rv_result) TYPE i.

    METHODS prepare_question
      IMPORTING
        it_question      TYPE string_table
      RETURNING
        VALUE(rs_result) TYPE lcl_questions=>ty_question.
    METHODS memorize_number
      IMPORTING
        iv_number TYPE i.
    METHODS find_unused_question_number
      IMPORTING
        io_generator     TYPE REF TO cl_abap_random_int
      RETURNING
        VALUE(rv_result) TYPE i.


ENDCLASS.

**********************************************************************

CLASS lcl_screen DEFINITION FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor.

    METHODS display.

    METHODS refresh.

    METHODS on_double_click FOR EVENT double_click OF cl_salv_events_table
      IMPORTING
          row
          column.

    METHODS on_toolbar_click FOR EVENT added_function OF cl_salv_events_table
      IMPORTING
          e_salv_function
          sender.

    EVENTS answer_given
      EXPORTING
        VALUE(iv_answer) TYPE i.

    EVENTS next_round.

    METHODS set_question
      IMPORTING
        is_question TYPE lcl_questions=>ty_question.

    METHODS output_message
      IMPORTING
        iv_message TYPE string.

    METHODS show_welcome_message.

    METHODS allow_painting.

    METHODS deny_painting.

    METHODS randomize_color.

  PRIVATE SECTION.
    TYPES: BEGIN OF screen_pixels_per_line,
             column_a TYPE char1,
             column_b TYPE char1,
             column_c TYPE char1,
             column_d TYPE char1,
             column_e TYPE char1,
             color    TYPE lvc_t_scol,
           END OF screen_pixels_per_line.

    TYPES screen_pixels TYPE TABLE OF screen_pixels_per_line WITH EMPTY KEY.

    DATA mo_screen TYPE REF TO cl_salv_table.
    DATA mt_screen_pixels TYPE screen_pixels.
    DATA mv_color_value TYPE i.
    DATA mv_painting_allowed TYPE abap_bool VALUE abap_false.
    DATA ms_question TYPE lcl_questions=>ty_question.

    METHODS define_color_column.

    METHODS register_screen_events.

    METHODS paint_cell
      IMPORTING
        iv_column_name TYPE salv_de_column
      CHANGING
        cs_screen_line LIKE LINE OF mt_screen_pixels.

    METHODS set_toolbar.

    METHODS init_paint_area.

    METHODS create_alv_as_screen.

    METHODS show_question.
ENDCLASS.

**********************************************************************

CLASS lcl_logic DEFINITION FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_game_phase TYPE char1.

    CONSTANTS: BEGIN OF co_game_phases,
                 quiz_mode  TYPE ty_game_phase VALUE 'Q',
                 paint_mode TYPE ty_game_phase VALUE 'P',
               END OF co_game_phases.

    METHODS constructor.

    METHODS get_question
      RETURNING
        VALUE(rs_result) TYPE lcl_questions=>ty_question.

    METHODS increment_round.

    METHODS is_game_over
      RETURNING
        VALUE(rv_result) TYPE abap_bool.

    METHODS is_answer_correct
      IMPORTING
        iv_answer        TYPE i
      RETURNING
        VALUE(rv_result) TYPE abap_bool.

    METHODS set_quiz_game_phase.

    METHODS set_paint_game_phase.

    METHODS get_game_phase
      RETURNING
        VALUE(rv_result) TYPE ty_game_phase.

  PRIVATE SECTION.
    DATA mo_questions TYPE REF TO lcl_questions.
    DATA mv_round TYPE i VALUE 1.
    DATA mv_phase TYPE ty_game_phase.
    DATA mv_right_answer TYPE i.

    METHODS do_absolutely_nothing.

ENDCLASS.

CLASS lcl_logic IMPLEMENTATION.

  METHOD constructor.
    mo_questions = NEW lcl_questions( ).
  ENDMETHOD.

  METHOD get_question.
    DATA(ls_question) = mo_questions->get_random_question( ).
    mv_right_answer = ls_question-right_answer.
    rs_result = ls_question.
  ENDMETHOD.

  METHOD is_answer_correct.
    IF iv_answer = mv_right_answer.
      rv_result = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_game_over.
    IF mv_round = 2.
      rv_result = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD increment_round.
    mv_round = mv_round + 1.
  ENDMETHOD.

  METHOD set_paint_game_phase.
    mv_phase = co_game_phases-paint_mode.
  ENDMETHOD.

  METHOD set_quiz_game_phase.
    mv_phase = co_game_phases-quiz_mode.
  ENDMETHOD.

  METHOD get_game_phase.
    rv_result = mv_phase.
  ENDMETHOD.

  METHOD do_absolutely_nothing.
    " This method is really doing nothing. So it's a good chance
    " to say thanks that you check my source code. Have fun!
  ENDMETHOD.

ENDCLASS.

**********************************************************************

CLASS lcl_game DEFINITION FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor.

    METHODS run.

  PRIVATE SECTION.
    DATA mo_screen TYPE REF TO lcl_screen.
    DATA mo_logic TYPE REF TO lcl_logic.

    METHODS on_next_round FOR EVENT next_round OF lcl_screen.

    METHODS on_answer_given FOR EVENT answer_given OF lcl_screen
      IMPORTING
          iv_answer.

    METHODS register_game_events.

    METHODS game_over
      RAISING
        lcx_error.

    METHODS handle_correct_answer.

    METHODS handle_incorrect_answer.

    METHODS take_and_save_screenshot.

ENDCLASS.

**********************************************************************

CLASS lcl_game IMPLEMENTATION.

  METHOD constructor.
    mo_logic = NEW lcl_logic( ).
    mo_screen = NEW lcl_screen( ).
    register_game_events( ).
  ENDMETHOD.

  METHOD run.
    mo_logic->set_quiz_game_phase( ).
    mo_screen->show_welcome_message( ).
    mo_screen->set_question( mo_logic->get_question( ) ).
    mo_screen->display( ).
  ENDMETHOD.

  METHOD on_next_round.
    TRY.
        IF mo_logic->get_game_phase( ) <> lcl_logic=>co_game_phases-paint_mode.
          mo_screen->output_message( 'Please answer the question first. Thanks!' ).
          RETURN.
        ENDIF.

        IF mo_logic->is_game_over( ).
          game_over( ).
        ENDIF.

        mo_logic->increment_round( ).
        mo_logic->set_quiz_game_phase( ).

        mo_screen->set_question( mo_logic->get_question( ) ).
        mo_screen->refresh( ).
      CATCH lcx_error.
    ENDTRY.
  ENDMETHOD.

  METHOD game_over.
    take_and_save_screenshot( ).
    MESSAGE 'Game is over. Back to work! Write Clean ABAP!' TYPE 'I'.
    LEAVE PROGRAM.
  ENDMETHOD.

  METHOD take_and_save_screenshot.
    TRY.
        DATA(lo_screenshot_maker) = NEW lcl_screenshot( ).
        lo_screenshot_maker->make_screenshot_and_save( ).
      CATCH lcx_error.
        " ok, no exception handling needed
    ENDTRY.
  ENDMETHOD.

  METHOD register_game_events.
    SET HANDLER on_next_round FOR mo_screen.
    SET HANDLER on_answer_given FOR mo_screen.
  ENDMETHOD.

  METHOD on_answer_given.
    TRY.
        IF mo_logic->get_game_phase( ) <> lcl_logic=>co_game_phases-quiz_mode.
          mo_screen->output_message( 'Concentrate on painting! Click next round when ready!' ).
          RETURN.
        ENDIF.

        IF mo_logic->is_answer_correct( iv_answer ).
          handle_correct_answer( ).
        ELSE.
          IF mo_logic->is_game_over( ).
            game_over( ).
          ENDIF.
          handle_incorrect_answer( ).
        ENDIF.

        mo_screen->refresh( ).
      CATCH lcx_error.
    ENDTRY.
  ENDMETHOD.

  METHOD handle_incorrect_answer.
    mo_logic->increment_round( ).

    mo_screen->deny_painting( ).
    mo_screen->output_message( 'No, not really! New question, new chance!' ).
    mo_screen->set_question( mo_logic->get_question( ) ).
  ENDMETHOD.

  METHOD handle_correct_answer.
    mo_logic->set_paint_game_phase( ).

    mo_screen->randomize_color( ).
    mo_screen->allow_painting( ).
    mo_screen->output_message( 'Correct! Time to paint! Let the artist out!' ).
  ENDMETHOD.

ENDCLASS.

**********************************************************************

CLASS lcl_questions IMPLEMENTATION.

  METHOD get_end_line_of_question.
    DATA lv_index TYPE i.
    DATA ls_question_index LIKE LINE OF mt_question_index.

    " use table with all positions of questions to find end line of next question
    READ TABLE mt_question_index INTO ls_question_index WITH KEY line = iv_start_line.
    IF sy-subrc <> 0.
    ENDIF.

    " try to read information of next question
    lv_index = sy-tabix + 1.

    READ TABLE mt_question_index INTO ls_question_index INDEX lv_index.
    IF sy-subrc = 0.
      " use line of next question as end line
      rv_result = ls_question_index-line - 1.
    ELSE.
      " end of lines reached
      rv_result = lines( mt_include_lines ).
    ENDIF.
  ENDMETHOD.

  METHOD get_question_by_number.
    DATA(lv_start_line) = get_start_line_of_question( iv_question_number ).
    DATA(lv_end_line) = get_end_line_of_question( lv_start_line ).

    rt_result = get_lines_of_question( iv_start_line = lv_start_line
                                       iv_end_line = lv_end_line ).
  ENDMETHOD.

  METHOD get_start_line_of_question.
    TRY.
        rv_result = mt_question_index[ iv_question_number ]-line.
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD read_include_content.
    READ REPORT iv_include_name INTO mt_include_lines.
    IF sy-subrc <> 0.
    ENDIF.
  ENDMETHOD.

  METHOD build_question_index.
    FIND ALL OCCURRENCES OF mc_question_marker IN TABLE mt_include_lines RESULTS mt_question_index.
    IF sy-subrc <> 0.
    ENDIF.
  ENDMETHOD.

  METHOD get_lines_of_question.
    LOOP AT mt_include_lines INTO DATA(ls_include_line) FROM iv_start_line TO iv_end_line.
      DATA(lv_length) = strlen( ls_include_line ).

      IF ls_include_line IS INITIAL OR lv_length <= 1.
        CONTINUE.
      ENDIF.

      IF ls_include_line+0(1) = '*' OR ls_include_line+0(1) = '"'.
        SHIFT ls_include_line LEFT DELETING LEADING '*'.
        SHIFT ls_include_line LEFT DELETING LEADING '"'.
      ENDIF.

      SHIFT ls_include_line LEFT DELETING LEADING space.

      IF ls_include_line CS mc_question_marker.
        SHIFT ls_include_line BY 4 PLACES LEFT.
      ENDIF.

      APPEND ls_include_line TO rt_result.
    ENDLOOP.
  ENDMETHOD.

  METHOD constructor.
    read_include_content( 'ZQPG_QUESTIONS_AND_ANSWERS' ).
    build_question_index( ).
  ENDMETHOD.

  METHOD get_random_question.
    DATA(lv_random_number) = get_random_question_number( ).
    IF lv_random_number IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_question) = get_question_by_number( lv_random_number ).
    rs_result = prepare_question( lt_question ).
  ENDMETHOD.

  METHOD get_random_question_number.
    DATA(lv_max_number) = lines( mt_question_index ).

    IF lv_max_number = lines( mt_number_memory ).
      RETURN.
    ENDIF.

    DATA(lo_generator) = cl_abap_random_int=>create( seed = CONV i( sy-uzeit )
                                                     min  = 1
                                                     max = lv_max_number ).

    rv_result = find_unused_question_number( lo_generator ).
  ENDMETHOD.

  METHOD prepare_question.
    LOOP AT it_question INTO DATA(ls_content).
      CASE sy-tabix.
        WHEN 1.
          rs_result-question = ls_content.
        WHEN 2.
          rs_result-answer_1 = ls_content.
        WHEN 3.
          rs_result-answer_2 = ls_content.
        WHEN 4.
          rs_result-answer_3 = ls_content.
        WHEN 5.
          rs_result-right_answer = ls_content.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD memorize_number.
    DATA(ls_number_memory) = VALUE ty_number_memory_entry( number = iv_number ).
    INSERT ls_number_memory INTO TABLE mt_number_memory.
    IF sy-subrc <> 0.
    ENDIF.
  ENDMETHOD.

  METHOD find_unused_question_number.
    DATA lv_random_number TYPE i.

    DO.
      lv_random_number = io_generator->get_next( ).

      IF line_exists( mt_number_memory[ number = lv_random_number ] ).
        CONTINUE.
      ELSE.
        memorize_number( lv_random_number ).
        EXIT.
      ENDIF.
    ENDDO.

    rv_result = lv_random_number.
  ENDMETHOD.

ENDCLASS.

**********************************************************************

CLASS lcl_screen IMPLEMENTATION.
  METHOD constructor.
    init_paint_area( ).
    create_alv_as_screen( ).
    define_color_column( ).
    show_question( ).
    show_welcome_message( ).
    register_screen_events( ).
    set_toolbar( ).
  ENDMETHOD.

  METHOD define_color_column.
    DATA(lo_columns) = mo_screen->get_columns( ).
    TRY.
        lo_columns->set_color_column( 'COLOR' ).
      CATCH cx_salv_data_error.
    ENDTRY.
  ENDMETHOD.

  METHOD display.
    mo_screen->display(  ).
  ENDMETHOD.

  METHOD paint_cell.
    DATA(ls_color) = VALUE lvc_s_scol( fname = iv_column_name
                                       color-col = mv_color_value
                                       color-int = 0
                                       color-inv = 0 ).

    APPEND ls_color TO cs_screen_line-color.
  ENDMETHOD.

  METHOD register_screen_events.
    SET HANDLER on_double_click FOR mo_screen->get_event( ).
    SET HANDLER on_toolbar_click FOR mo_screen->get_event( ).
  ENDMETHOD.

  METHOD on_double_click.
    IF mv_painting_allowed = abap_false.
      RETURN.
    ENDIF.

    TRY.
        ASSIGN mt_screen_pixels[ row ] TO FIELD-SYMBOL(<screen_line>).
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    paint_cell(
      EXPORTING
        iv_column_name = column
      CHANGING
        cs_screen_line = <screen_line> ).

    mo_screen->refresh( ).
  ENDMETHOD.

  METHOD set_toolbar.
    mo_screen->set_screen_status(
                 EXPORTING
                   report        = sy-repid
                   pfstatus      = 'SCREEN_FUNCTIONS' ).
  ENDMETHOD.

  METHOD on_toolbar_click.
    CASE e_salv_function.
      WHEN 'ANSWER_1'.
        RAISE EVENT answer_given
          EXPORTING
            iv_answer = 1.

      WHEN 'ANSWER_2'.
        RAISE EVENT answer_given
          EXPORTING
            iv_answer = 2.

      WHEN 'ANSWER_3'.
        RAISE EVENT answer_given
          EXPORTING
            iv_answer = 3.

      WHEN 'NEXT_ROUND'.
        RAISE EVENT next_round.
    ENDCASE.
  ENDMETHOD.

  METHOD init_paint_area.
    mt_screen_pixels = VALUE #( FOR i = 1 UNTIL i = 5 ( ) ).
  ENDMETHOD.

  METHOD create_alv_as_screen.
    TRY.
        cl_salv_table=>factory(
                         IMPORTING
                           r_salv_table = mo_screen
                         CHANGING
                           t_table      = mt_screen_pixels ).

      CATCH cx_salv_msg.
    ENDTRY.
  ENDMETHOD.

  METHOD show_question.
    DATA(lo_header) = NEW cl_salv_form_layout_grid( ).

    lo_header->create_header_information( row     = 1
                                          column  = 1
                                          text    = 'Question and answers'
                                          tooltip = space ).

    lo_header->add_row( ).

    DATA(o_grp_sel) = NEW cl_salv_form_groupbox( header = ms_question-question ).
    lo_header->set_element( row = 4 column = 1 r_element = o_grp_sel ).

    DATA(o_grp_head_grid) = o_grp_sel->create_grid( ).
    o_grp_head_grid->set_grid_lines( if_salv_form_c_grid_lines=>no_lines ).

    DATA(o_label_v) = o_grp_head_grid->create_label( row = 1 column = 1 text = |1)| ).
    DATA(o_text_v) = o_grp_head_grid->create_text( row = 1 column = 2 text = |{ ms_question-answer_1 }| ).
    o_label_v->set_label_for( o_text_v ).

    DATA(o_label_v2) = o_grp_head_grid->create_label( row = 2 column = 1 text = |2)| ).
    DATA(o_text_v2) = o_grp_head_grid->create_text( row = 2 column = 2 text = |{ ms_question-answer_2 }| ).
    o_label_v2->set_label_for( o_text_v2 ).

    DATA(o_label_v3) = o_grp_head_grid->create_label( row = 3 column = 1 text = |3)| ).
    DATA(o_text_v3) = o_grp_head_grid->create_text( row = 3 column = 2 text = |{ ms_question-answer_3 }| ).
    o_label_v3->set_label_for( o_text_v3 ).

    mo_screen->set_top_of_list( lo_header ).
    mo_screen->set_top_of_list_height( 30 ).
  ENDMETHOD.

  METHOD show_welcome_message.
    DATA(lo_footer) = NEW cl_salv_form_layout_grid( ).
    lo_footer->create_header_information( row     = 1
                                          column  = 1
                                          text    = 'Welcome to quiz and paint game.'
                                          tooltip = space ).

    mo_screen->set_end_of_list( lo_footer ).
    mo_screen->set_end_of_list_height( 10 ).
  ENDMETHOD.

  METHOD randomize_color.
    DATA(lo_random) = cl_abap_random_int=>create( seed = CONV i( sy-uzeit )
                                                  min  = 1
                                                  max = 7 ).

    mv_color_value = lo_random->get_next( ).
  ENDMETHOD.

  METHOD set_question.
    ms_question = is_question.
    show_question( ).
  ENDMETHOD.

  METHOD refresh.
    DATA(ls_stable) = VALUE lvc_s_stbl( col = abap_true
                                        row = abap_true ).

    mo_screen->refresh( s_stable     = ls_stable
                        refresh_mode = if_salv_c_refresh=>full ).
  ENDMETHOD.

  METHOD output_message.
    DATA(lo_footer) = NEW cl_salv_form_layout_grid( ).

    lo_footer->create_header_information( row     = 1
                                          column  = 1
                                          text    = iv_message
                                          tooltip = space ).

    mo_screen->set_end_of_list( lo_footer ).
    mo_screen->set_end_of_list_height( 10 ).
  ENDMETHOD.

  METHOD allow_painting.
    mv_painting_allowed = abap_true.
  ENDMETHOD.

  METHOD deny_painting.
    mv_painting_allowed = abap_false.
  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.
  DATA(go_game) = NEW lcl_game( ).
  go_game->run( ).
