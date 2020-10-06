
CC = $(CROSS_COMPILE)gcc
AR = $(CROSS_COMPILE)ar
HOSTCC = gcc
ARCH=riscv
IFLAGS = -I$(TOPDIR)/include
DFLAGS = -g
OFLAGS = -Og -fomit-frame-pointer
CFLAGS = -Wall -Werror -static $(IFLAGS) $(DFLAGS) $(OFLAGS) -D__riscv__ -march=${MARCH}
LDFLAGS = -march=${MARCH} -static

SRCS += $(wildcard *.c)
OBJS += $(subst .c,.o,$(SRCS))
HDRS += $(wildcard *.h)
HDRS += $(wildcard $(TOPDIR)/include/*.h)
SUBDIRS_CLEAN += $(addsuffix _clean_,$(SUBDIRS))

.PHONY:		all clean $(SUBDIRS) $(SUBDIRS_CLEAN)


all:		.depend $(TARGET) $(A_TARGET) $(HOST_TARGET)

$(SUBDIRS):
		$(MAKE) -C $@

$(TARGET):	$(OBJS) $(SUBDIRS)
		$(CC) -o $(TARGET) $(LDFLAGS) $(filter $(OBJS), $^) $(LIBS)

$(A_TARGET):	$(OBJS)
		$(AR) -rcs $(A_TARGET) $(OBJS)

$(HOST_TARGET):	$(SRCS)
		$(HOSTCC) -o $(HOST_TARGET) $(CFLAGS) $(SRCS) $(LIBS)


clean::		$(SUBDIRS_CLEAN)
		$(RM) $(TARGET) $(A_TARGET) $(HOST_TARGET) $(OBJS) .depend

$(SUBDIRS_CLEAN):
		$(MAKE) -C $(subst _clean_,,$@) clean


%.o:		%.c
		$(CC) -c $(CFLAGS) -o $@ $<


ifeq ($(HOST_TARGET),)
DEPCC = $(CC)
else
DEPCC = $(HOSTCC)
endif

.depend:	$(SRCS) $(HDRS)
		$(DEPCC) -M $(CFLAGS) $(SRCS) > .depend

ifneq ($(MAKECMDGOALS),clean)
-include .depend
endif

