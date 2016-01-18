/*******************************************************************************
  * @file      STM32F0xxxx.ld
  * @author    Evan Hunter
  * @version   V1.0
  * @date      5-2-2015
  * @brief     Link script for STM32F0 series microcontrollers
  *            Includes sections that enable C++ functionality, but which
  *            slightly increase the memory usage
  ******************************************************************************
  * Copyright (c) 2015, Evan Hunter
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without modification,
  * are permitted provided that the following conditions are met:
  *   1. Redistributions of source code must retain the above copyright notice,
  *      this list of conditions and the following disclaimer.
  *   2. Redistributions in binary form must reproduce the above copyright notice,
  *      this list of conditions and the following disclaimer in the documentation
  *      and/or other materials provided with the distribution.
  *   3. Neither the name of STMicroelectronics nor the names of its contributors
  *      may be used to endorse or promote products derived from this software
  *      without specific prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
  * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  *
  ******************************************************************************/

/* Include the memory details for the specific */
INCLUDE stm32_memory.ld

ENTRY(Reset_Handler);

PROVIDE( MIN_STACK_SIZE = 128 );

SECTIONS
{
	. = ALIGN(4);

	.text :
	{
		_stext = .;
		__stext = .;
		
		/* Interrupt vector table - requires keep() since it is not referenced by functions */
		KEEP( *(.isr_vector) );
		
		/* Reset handler - Put this first for neatness */
		*(.text.Reset_Handler);
		
		/* All other code */
		*(.text .text*);
		
		/* Special init functions run before main */
		KEEP(*(.init));
		KEEP(*(.fini));

		/* Old style Constructors */
		*crtbegin.o(.ctors)
		*crtbegin?.o(.ctors)
		*(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
		*(SORT(.ctors.*))
		*(.ctors)

		/* Old style Destructors */
 		*crtbegin.o(.dtors)
 		*crtbegin?.o(.dtors)
 		*(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
 		*(SORT(.dtors.*))
 		*(.dtors)
		
		. = ALIGN(4);
		_etext = .;
		__etext = .;
	} > FLASH

	. = ALIGN(4);
		
	.rodata :
	{
		_srodata = .;
		
		/* Read only (const) variables */
		*(.rodata .rodata*)
		
		/* Virtual function tables */
		*(vtable);

		/* Java compiled classes register */
		_sjcr = .;
		KEEP(*(.jcr*));
		_ejcr = .;
		
		. = ALIGN(4);
		_erodata = .;
	} > FLASH
	
	. = ALIGN(4);

	.eh_frame :
	{
		/* Data for stack frame unwinding during exception handling */
		KEEP(*(.eh_frame*))
		. = ALIGN(4);
	} > FLASH

	. = ALIGN(4);
	
	.ARM.extab :
	{
		/* Data for stack frame unwinding during exception handling */
		*(.ARM.extab*)
		*(.gnu.linkonce.armextab.*)
	} > FLASH
 
 	. = ALIGN(4);
	
	.ARM.exidx :
	{
		/* Indexs for unwinding */
		__exidx_start = .;
		*(.ARM.exidx*)
		*(.gnu.linkonce.armexidx.*)
		__exidx_end = .;
	} > FLASH
	
	. = ALIGN(4);

	.preinit_array :
	{
		/*  An array of pointers to functions that pre-init global scoped objects */
		PROVIDE_HIDDEN (__preinit_array_start = .);
		KEEP(*(.preinit_array*));
		PROVIDE_HIDDEN (__preinit_array_end = .);
	} >FLASH

	. = ALIGN(4);

	.init_array :
	{
		/* An array of pointers to functions that init (construct) global scoped objects - used by __libc_init_array */
		PROVIDE_HIDDEN (__init_array_start = .);
		KEEP(*(SORT(.init_array.*)));
		KEEP(*(.init_array*));
		PROVIDE_HIDDEN (__init_array_end = .);
	} >FLASH

	. = ALIGN(4);

	.fini_array :
	{
		/* An array of pointers to functions that deinit (destruct) global scoped objects - used by __libc_fini_array */
		PROVIDE_HIDDEN (__fini_array_start = .);
		KEEP(*(SORT(.fini_array.*)));
		KEEP(*(.fini_array*));
		PROVIDE_HIDDEN (__fini_array_end = .);
	} >FLASH
	
	. = ALIGN(4);

	.data :
	{
		/* Global scope variable data with non-zero initial values */
		_sdata = .;
		__data_start__ = .;
		*(.data .data*);
		. = ALIGN(4);
		_edata = .;
		__data_end__ = .;
	} > RAM AT>FLASH
	_sidata = LOADADDR(.data);  /* Location where initial values are stored in flash for copying during crt0 */
	_eidata = _sidata + SIZEOF(.data);
	
	. = ALIGN(4);
	
	.bss :
	{
		/* Global scope variable data with zero initial values - blanked during crt0 */
		_sbss = .;
		__bss_start__ = .;
		*(.bss .bss*);
		*(COMMON)   /* Variables not explicitly assigned zero initial value - standard gives implicit zero */
		. = ALIGN(4);
		_ebss = .;
		__bss_end__ = .;
	} > RAM
	
	. = ALIGN(4);
	
	.stack :
	{
		/* Initial stack - can be sized by assigning variables to .stack section or by defining MIN_STACK_SIZE on commandline */
		_sstack = .;
		__StackLimit = .;
		*(.stack .stack*)
		. = MAX( _sstack + MIN_STACK_SIZE, . );
		. = ALIGN(4);
		_estack = .;
		__stack = .;
		__StackTop = .;
	} > RAM
	
	. = ALIGN(4);

	.heap :
	{
		/* Dynamic memory (malloc/free) area - extends to end of RAM */
		_sheap = .;
		__end__ = .;
		PROVIDE(end = .);
		*(.heap*)
		. = ORIGIN(RAM) + LENGTH(RAM);
		_eheap = .;
		__HeapLimit = .;
	}

	/DISCARD/ :
	{
		/* Discard everything else */
		*(*);
	}
}


/* Provide an indication of whether there are actually global objects that need init 
 * The functions and arrays used for global objects and stack unwinding use some
 * memory regardless of whether they are used.
 */
/* .init_array = 4 call to frame_dummy */
/* .eh_frame = 4 - null terminator */
/* .jcr = 4 - null terminator */
CPP_INIT_NEEDED = ((SIZEOF(.preinit_array)==0) && (SIZEOF(.init_array)==4) && (SIZEOF(.eh_frame)==4) && ((_ejcr - _sjcr)==4))? 0 : 1;


