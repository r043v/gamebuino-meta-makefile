LDSCRIPT = gamebuino/samd21g18a_flash.ld
#LDSCRIPT = gamebuino/flash_with_bootloader.ld

PTYPE=__SAMD21G18A__

CC=arm-none-eabi-gcc
LD=arm-none-eabi-gcc
AR=arm-none-eabi-ar
AS=arm-none-eabi-as
OBJCOPY=arm-none-eabi-objcopy

ELF=$(notdir $(CURDIR)).elf
BIN=$(notdir $(CURDIR)).bin

ASF_ROOT=./gamebuino/asf
#ASF_ROOT=../xdk-asf-3.50.0

INCLUDES= \
          sam0/utils/cmsis/samd21/include \
          sam0/utils/cmsis/samd21/source \
          thirdparty/CMSIS/Include \
          thirdparty/CMSIS/Lib/GCC

OBJS = gamebuino/startup_samd21.o main.o

#LDFLAGS+= -T$(LDSCRIPT) -mthumb -mcpu=cortex-m0 -Wl,--gc-sections,--print-memory-usage,--defsym,__stack_size__=0x500
LDFLAGS+= -T$(LDSCRIPT) -Wl,--print-memory-usage -Wl,--gc-sections -Wl,-n -mcpu=cortex-m0plus -mthumb -Wl,--undefined=g_pfnVectors -Wl,--undefined=boot -Wl,--start-group -lstdc++ -lsupc++ -lm -lc -lgcc -lnosys -Wl,--end-group -Wl,--defsym,__stack_size__=0x500

CFLAGS+= -mcpu=cortex-m0 -mthumb -g
CFLAGS+= $(INCLUDES:%=-I $(ASF_ROOT)/%) -I .
CFLAGS+= -D$(PTYPE)

#CFLAGS+=-Wno-pointer-arith -c -fno-exceptions -ffunction-sections -fdata-sections -funsigned-char -MMD -fno-delete-null-pointer-checks -fomit-frame-pointer -mcpu=cortex-m0plus -mthumb -Wno-psabi -DTARGET_CORTEX -DTARGET_CORTEX_M -DTARGET_M0P -DTARGET_LIKE_CORTEX_M0 -D__CORTEX_M0PLUS -DARM_MATH_CM0PLUS -DTOOLCHAIN_object -D__CMSIS_RTOS -DTOOLCHAIN_GCC -DTOOLCHAIN_GCC_ARM -DDEVICE_I2C=1 -DDEVICE_I2CSLAVE=1 -DDEVICE_RTC=1 -DDEVICE_SERIAL=1 -DDEVICE_SLEEP=1 -DDEVICE_SPI=1 -DDEVICE_ANALOGIN=1 -DDEVICE_PWMOUT=1 -DTARGET_UVISOR_UNSUPPORTED -DDEVICE_INTERRUPTIN=1 -DTARGET_FF_ARDUINO -DTARGET_RELEASE

CFLAGS+=-pipe -Wall -Wstrict-prototypes -Wmissing-prototypes -Werror-implicit-function-declaration \
-Wpointer-arith -std=gnu99 -fno-strict-aliasing -ffunction-sections -fdata-sections \
-Wchar-subscripts -Wcomment -Wformat=2 -Wimplicit-int -Wmain -Wparentheses -Wsequence-point \
-Wreturn-type -Wswitch -Wtrigraphs -Wunused -Wuninitialized -Wunknown-pragmas -Wfloat-equal \
-Wundef -Wshadow -Wbad-function-cast -Wwrite-strings -Wsign-compare -Waggregate-return \
-Wmissing-declarations -Wformat -Wmissing-format-attribute -Wno-deprecated-declarations \
-Wpacked -Wredundant-decls -Wnested-externs -Wlong-long -Wunreachable-code -Wcast-align \
--param max-inline-insns-single=500

$(ELF):     $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)
	$(OBJCOPY) -O binary $(ELF) $(BIN)

# compile and generate dependency info

%.o:    %.c
	$(CC) -c $(CFLAGS) $< -o $@
	$(CC) -MM $(CFLAGS) $< > $*.d

%.o:    %.s
	$(AS) $< -o $@

info:
	@echo CFLAGS=$(CFLAGS)
	@echo OBJS=$(OBJS)

clean:
	rm -f $(OBJS) $(OBJS:.o=.d) $(ELF) $(BIN) $(CLEANOTHER)

debug:  $(ELF)
	arm-none-eabi-gdb -iex "target extended-remote localhost:3333" $(ELF)

-include    $(OBJS:.o=.d)
