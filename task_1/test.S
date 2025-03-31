.section .data
.align 8
buffer:
    .fill 256, 1, 0
.align 8
filename:
    .asciz "testfile.txt"
.align 8
message:
    .asciz "Hello, ARM64!\nMy name is Daria Korotych\n"
message_end:
.align 8
error_msg:
    .asciz "Error: File creation failed\n"
error_msg_end:
.align 8
error_change_permissions:
    .asciz "Error: Permissions didn't change\n"
error_change_permissions_end:
.align 8
errno_msg:
    .asciz "Errno: "
errno_msg_end:
.align 8
errno_value:
    .fill 12, 1, 0 
.align 8
file_content_msg:
    .asciz "\nFile content:\n"
file_content_msg_end:

.section .bss
    fd: .skip 8 // Allocate space for file descriptor

.section .text
.global _start

_start:
    // Read from STDIN into buffer (optional user input)
    ldr x0, =buffer
    mov x1, #256
    mov x8, #17
    svc #0

    // Write buffer to STDOUT (prints user input)
    mov x0, #1
    ldr x1, =buffer
    mov x2, #256
    mov x8, #64
    svc #0

    // Create file "testfile.txt" with flags and mode (O_RDWR|O_CREAT|O_TRUNC)
    mov x0, -100              // AT_FDCWD
    ldr x1, =filename
    mov x2, #0x242            // 0x242 = O_RDWR|O_CREAT|O_TRUNC (2+64+512)
    mov x3, #0644
    mov x8, #56
    svc #0
    mov x20, x0              // Save file descriptor or error code

    // Check if file creation failed
    cmp x0, #0
    blt error_exit

    // Write message to the file using computed length
    mov x0, x20
    ldr x1, =message
    mov x2, message_end - message
    mov x8, #64
    svc #0

    // Clear buffer (set all 256 bytes to zero)
    mov x0, #0
    mov x2, #256
    ldr x1, =buffer
clear_buffer:
    strb w0, [x1, x0]
    add x0, x0, #1
    cmp x0, #256
    blt clear_buffer

    // Reset file offset to beginning
    mov x0, x20
    mov x1, #0
    mov x2, #0
    mov x8, #62
    svc #0

    // Read file contents back into buffer
    mov x0, x20
    ldr x1, =buffer
    mov x2, #256
    mov x8, #63
    svc #0
    // Save the number of bytes read in x22
    mov x22, x0

    // Print "File content:" header using computed length
    mov x0, #1
    ldr x1, =file_content_msg
    mov x2, file_content_msg_end - file_content_msg
    mov x8, #64
    svc #0

    // Write file contents (only the bytes that were read)
    mov x0, #1
    ldr x1, =buffer
    mov x2, x22             // Use the actual number of bytes read
    mov x8, #64
    svc #0

    // Close the file
    mov x0, x20
    mov x8, #57
    svc #0

    // Exit normally
    mov x0, #1
    mov x8, #93
    svc #0

error_exit:
    // Print file creation error message using computed length
    mov x0, #2
    ldr x1, =error_msg
    mov x2, error_msg_end - error_msg
    mov x8, #64
    svc #0

    // Print errno prefix
    mov x0, #2
    ldr x1, =errno_msg
    mov x2, errno_msg_end - errno_msg
    mov x8, #64
    svc #0

    // Convert file creation error code to string (x20 holds the error)
    mov x0, x20
    neg x0, x0       // Negate to get positive errno
    ldr x1, =errno_value
    bl int_to_str

    // Print the errno value
    mov x0, #2
    ldr x1, =errno_value
    mov x2, #12
    mov x8, #64
    svc #0

    // Exit with error
    mov x0, #1
    mov x8, #93
    svc #0

int_to_str:
    mov x2, #10
    add x1, x1, #11
    mov w3, #0
    strb w3, [x1], #-1

int_to_str_loop:
    udiv x3, x0, x2
    msub x4, x3, x2, x0
    add x4, x4, #48
    strb w4, [x1], #-1
    mov x0, x3
    cmp x0, #0
    bne int_to_str_loop

    mov x0, x1
    ret
