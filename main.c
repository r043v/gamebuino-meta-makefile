#include <samd21.h>

int main(void){
  // disable watchdog
  WDT->CTRL.bit.ENABLE = 0;

  // back to bootloader
  ((void(*)(void))(*((uint32_t*)0x3FF4)))();
}
