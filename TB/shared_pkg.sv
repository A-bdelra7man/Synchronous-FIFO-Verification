package shared_pkg;
    bit test_finished = 0;
    integer error_count = 0;
    integer correct_count = 0;
    // event to synchronize monitor after TB drives stimulus
    event sample_event;
endpackage
