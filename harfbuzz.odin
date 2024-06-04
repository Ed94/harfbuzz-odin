/*
NOTE(Ed): These bindings are currently partial for usage in a VE Font Cache port.
*/
package harfbuzz

import "core:c"

when ODIN_OS == .Windows {
	foreign import harfbuzz "./lib/win64/libharfbuzz-0.dll"
}

Buffer :: distinct rawptr // hb_buffer_t
Blob   :: distinct rawptr // hb_blob_t
Face   :: distinct rawptr // hb_face_t
Font   :: distinct rawptr // hb_font_t

Memory_Mode :: enum c.int {
	DUPLICATE,
	READONLY,
	WRITABLE,
	READONLY_MAY_MAKE_WRITABLE,
}

Destroy_Func :: proc "c" ( user_data : rawptr )

@(default_calling_convention="c", link_prefix="hb_")
foreign harfbuzz {
	blob_create  :: proc( data : [^]u8, length : c.uint, memory_mode : Memory_Mode, user_data : rawptr, destroy : Destroy_Func ) -> Blob ---
	blob_destroy :: proc( blob : Blob ) ---

	buffer_create  :: proc() -> Buffer ---
	buffer_destory :: proc( buffer : Buffer) ---

	face_create  :: proc( blob : Blob, index : c.uint ) -> Face ---
	face_destroy :: proc( face : Face ) ---

	font_create  :: proc( face : Face ) -> Font ---
	font_destroy :: proc( font : Font ) ---
}
