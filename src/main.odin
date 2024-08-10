package jni

import "core:fmt"
import "core:os"
import "core:path/slashpath"

import "deps:bindgen"

//JNI_HEADER :: #load("../decls.h", string)

when ODIN_OS == .Linux {
    INCLUDE_SUBDIR :: "linux"
} else when ODIN_OS == .Windows {
    INCLUDE_SUBDIR :: "win32"
} else {
    #panic("unhandled")
}

main :: proc() {
	jni_include_root := find_include_root()

	config := bindgen.Config {
		root          = jni_include_root,
		files         = {"jni.h"},
		output        = "out",
		include_dirs  = {
            jni_include_root,
			"/usr/include/",
			slashpath.join({jni_include_root, INCLUDE_SUBDIR}),
		},
		package_name  = "jni",
		use_cstring   = true,
		use_odin_enum = true,
		indent_width  = 4,
	}

	bindgen.generate(config)

	if true do return
	/*
    lexer := lexer_new(JNI_HEADER, false)
    parser := parser_new(&lexer)

    decls := parse_decls(&parser)
    for decl in decls {
        fmt.println(decl)
    }
    */
}

// confirmed that jni.h is located under JAVA_HOME/include and not
// JAVA_HOME/include/win32 on windows, only jni_md.h is located there.
@(private)
find_include_root :: proc(allocator := context.temp_allocator) -> string {
	if java_home, found := os.lookup_env("JAVA_HOME", allocator); found {
		fmt.println(java_home)
		return slashpath.join({java_home, "/include"})
	}

	unimplemented("TODO")
}
