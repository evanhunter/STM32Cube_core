/* STM32F103xF */
MEMORY
{
	FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 768K
	RAM   (rxw) : ORIGIN = 0x20000000, LENGTH =  96K
}