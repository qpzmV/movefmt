module complex_module {  
  
    // Struct with various comment styles and positions  
    struct ComplexStruct3 {  
        // Field 1 comment (single-line)  
        field1: u64, // Inline comment (single-line)  
        /* Field 2 comment (multi-line) */  
        field2: /* Inline comment (multi-line) */ bool, // Trailing comment (single-line)  
    } // Struct footer comment (single-line)  
  
    // Function using the struct  
    fun use_complex_struct3(s: ComplexStruct3) {  
        // Function comment (single-line)  
    }  
}
