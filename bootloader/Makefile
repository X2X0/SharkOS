# =============================================================================
# SharkOS Makefile - Complete Build System
# =============================================================================
# A comprehensive build system for SharkOS - the collaborative AI-developed OS
# Supports bootloader compilation, kernel building, and disk image creation
# =============================================================================

# =============================================================================
# Configuration Variables
# =============================================================================

# Project directories
PROJECT_ROOT = .
BOOTLOADER_DIR = bootloader
KERNEL_DIR = kernel
BUILD_DIR = build
TOOLS_DIR = tools

# Assembler and compiler settings
ASM = nasm
CC = gcc
LD = ld
OBJCOPY = objcopy
QEMU = qemu-system-x86_64

# Assembler flags
ASMFLAGS = -f bin

# Compiler flags for kernel
CFLAGS = -m64 -ffreestanding -fno-stack-protector -fno-builtin -nostdlib \
         -Wall -Wextra -Werror -std=c99 -mcmodel=large -mno-red-zone \
         -mno-mmx -mno-sse -mno-sse2

# Linker flags
LDFLAGS = -T $(KERNEL_DIR)/linker.ld -nostdlib

# Output files
STAGE1_BIN = $(BUILD_DIR)/stage1.bin
STAGE2_BIN = $(BUILD_DIR)/stage2.bin
BOOTLOADER_BIN = $(BUILD_DIR)/bootloader.bin
KERNEL_BIN = $(BUILD_DIR)/kernel.bin
SHARKOS_IMG = $(BUILD_DIR)/sharkos.img

# Source files
BOOTLOADER_SOURCES = $(BOOTLOADER_DIR)/stage1.asm $(BOOTLOADER_DIR)/stage2.asm
KERNEL_SOURCES = $(wildcard $(KERNEL_DIR)/*.c)
KERNEL_OBJECTS = $(KERNEL_SOURCES:$(KERNEL_DIR)/%.c=$(BUILD_DIR)/%.o)

# =============================================================================
# Default Target
# =============================================================================

.PHONY: all
all: directories bootloader kernel disk-image
	@echo "🦈 SharkOS build complete!"
	@echo "   Bootloader: $(BOOTLOADER_BIN)"
	@echo "   Kernel:     $(KERNEL_BIN)"
	@echo "   Disk Image: $(SHARKOS_IMG)"

# =============================================================================
# Directory Setup
# =============================================================================

.PHONY: directories
directories:
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(TOOLS_DIR)

# =============================================================================
# Bootloader Build Targets
# =============================================================================

.PHONY: bootloader
bootloader: $(BOOTLOADER_BIN)

$(BOOTLOADER_BIN): $(STAGE1_BIN) $(STAGE2_BIN)
	@echo "🔧 Combining bootloader stages..."
	@cat $(STAGE1_BIN) $(STAGE2_BIN) > $(BOOTLOADER_BIN)
	@echo "✅ Bootloader created: $(BOOTLOADER_BIN)"

$(STAGE1_BIN): $(BOOTLOADER_DIR)/stage1.asm $(BOOTLOADER_DIR)/animation.asm \
               $(BOOTLOADER_DIR)/print.asm $(BOOTLOADER_DIR)/kernel_loader.asm
	@echo "🔧 Assembling Stage 1 (MBR)..."
	@$(ASM) $(ASMFLAGS) -o $(STAGE1_BIN) $(BOOTLOADER_DIR)/stage1.asm
	@echo "✅ Stage 1 assembled: $(STAGE1_BIN)"

$(STAGE2_BIN): $(BOOTLOADER_DIR)/stage2.asm $(BOOTLOADER_DIR)/gdt.asm \
               $(BOOTLOADER_DIR)/a20.asm $(BOOTLOADER_DIR)/paging.asm \
               $(BOOTLOADER_DIR)/longmode.asm
	@echo "🔧 Assembling Stage 2 (Extended Bootloader)..."
	@$(ASM) $(ASMFLAGS) -o $(STAGE2_BIN) $(BOOTLOADER_DIR)/stage2.asm
	@echo "✅ Stage 2 assembled: $(STAGE2_BIN)"

# =============================================================================
# Kernel Build Targets
# =============================================================================

.PHONY: kernel
kernel: $(KERNEL_BIN)

$(KERNEL_BIN): $(KERNEL_OBJECTS) $(KERNEL_DIR)/linker.ld
	@echo "🔧 Linking kernel..."
	@$(LD) $(LDFLAGS) -o $(KERNEL_BIN) $(KERNEL_OBJECTS)
	@echo "✅ Kernel linked: $(KERNEL_BIN)"

$(BUILD_DIR)/%.o: $(KERNEL_DIR)/%.c
	@echo "🔧 Compiling $<..."
	@$(CC) $(CFLAGS) -c $< -o $@

# =============================================================================
# Disk Image Creation
# =============================================================================

.PHONY: disk-image
disk-image: $(SHARKOS_IMG)

$(SHARKOS_IMG): $(BOOTLOADER_BIN) $(KERNEL_BIN)
	@echo "🔧 Creating disk image..."
	@dd if=/dev/zero of=$(SHARKOS_IMG) bs=1M count=10 2>/dev/null
	@dd if=$(BOOTLOADER_BIN) of=$(SHARKOS_IMG) bs=512 count=1 conv=notrunc 2>/dev/null
	@dd if=$(KERNEL_BIN) of=$(SHARKOS_IMG) bs=512 seek=10 conv=notrunc 2>/dev/null
	@echo "✅ Disk image created: $(SHARKOS_IMG)"

# =============================================================================
# Testing and Emulation
# =============================================================================

.PHONY: test
test: $(SHARKOS_IMG)
	@echo "🦈 Launching SharkOS in QEMU..."
	@$(QEMU) -drive format=raw,file=$(SHARKOS_IMG) -m 512M -cpu qemu64

.PHONY: test-debug
test-debug: $(SHARKOS_IMG)
	@echo "🦈 Launching SharkOS in QEMU with debugging..."
	@$(QEMU) -drive format=raw,file=$(SHARKOS_IMG) -m 512M -cpu qemu64 -s -S

.PHONY: test-kvm
test-kvm: $(SHARKOS_IMG)
	@echo "🦈 Launching SharkOS in QEMU with KVM acceleration..."
	@$(QEMU) -drive format=raw,file=$(SHARKOS_IMG) -m 512M -cpu host -enable-kvm

.PHONY: test-bochs
test-bochs: $(SHARKOS_IMG)
	@echo "🦈 Launching SharkOS in Bochs..."
	@echo "boot: disk" > $(BUILD_DIR)/bochsrc
	@echo "ata0-master: type=disk, path=\"$(SHARKOS_IMG)\", mode=flat" >> $(BUILD_DIR)/bochsrc
	@echo "megs: 512" >> $(BUILD_DIR)/bochsrc
	@echo "display_library: x" >> $(BUILD_DIR)/bochsrc
	@bochs -f $(BUILD_DIR)/bochsrc

# =============================================================================
# Analysis and Debugging Tools
# =============================================================================

.PHONY: analyze
analyze: $(BOOTLOADER_BIN) $(KERNEL_BIN)
	@echo "🔍 Analyzing bootloader..."
	@hexdump -C $(BOOTLOADER_BIN) | head -20
	@echo ""
	@echo "🔍 Bootloader size: $$(stat -c%s $(BOOTLOADER_BIN)) bytes"
	@echo "🔍 Kernel size: $$(stat -c%s $(KERNEL_BIN)) bytes"

.PHONY: disasm-bootloader
disasm-bootloader: $(BOOTLOADER_BIN)
	@echo "🔍 Disassembling bootloader..."
	@objdump -D -b binary -m i8086 $(STAGE1_BIN) | head -30
	@echo ""
	@objdump -D -b binary -m i386 $(STAGE2_BIN) | head -30

.PHONY: disasm-kernel
disasm-kernel: $(KERNEL_BIN)
	@echo "🔍 Disassembling kernel..."
	@objdump -D $(KERNEL_BIN) | head -50

.PHONY: verify-boot-signature
verify-boot-signature: $(STAGE1_BIN)
	@echo "🔍 Verifying boot signature..."
	@if [ "$$(tail -c 2 $(STAGE1_BIN) | hexdump -e '1/1 "%02X"')" = "55AA" ]; then \
		echo "✅ Boot signature is correct (0x55AA)"; \
	else \
		echo "❌ Boot signature is incorrect!"; \
		exit 1; \
	fi

# =============================================================================
# Kernel Stub Generation
# =============================================================================

.PHONY: kernel-stub
kernel-stub: directories
	@echo "🔧 Creating kernel stub..."
	@mkdir -p $(KERNEL_DIR)
	@cat > $(KERNEL_DIR)/kernel.c << 'EOF'
/* =============================================================================
 * SharkOS Kernel - Entry Point
 * =============================================================================
 * Basic kernel stub for SharkOS - the collaborative AI-developed OS
 * ============================================================================= */

void kernel_main(void) {
    // VGA text mode buffer
    volatile char *video = (volatile char*)0xB8000;
    const char *message = "SharkOS Kernel Loaded Successfully! 🦈";
    
    // Clear screen (80x25 characters, 2 bytes per character)
    for (int i = 0; i < 80 * 25 * 2; i++) {
        video[i] = 0;
    }
    
    // Display message in white on black
    int i = 0;
    while (message[i] != '\0') {
        video[i * 2] = message[i];        // Character
        video[i * 2 + 1] = 0x07;          // Attribute (white on black)
        i++;
    }
    
    // Kernel main loop
    while (1) {
        // Halt and wait for interrupts
        asm volatile("hlt");
    }
}
EOF
	@cat > $(KERNEL_DIR)/linker.ld << 'EOF'
/* =============================================================================
 * SharkOS Kernel Linker Script
 * ============================================================================= */

ENTRY(kernel_main)

SECTIONS {
    . = 0x100000;
    
    .text : {
        *(.text)
    }
    
    .rodata : {
        *(.rodata)
    }
    
    .data : {
        *(.data)
    }
    
    .bss : {
        *(.bss)
    }
}
EOF
	@echo "✅ Kernel stub created in $(KERNEL_DIR)/"

# =============================================================================
# Installation and Distribution
# =============================================================================

.PHONY: install
install: $(SHARKOS_IMG)
	@echo "🔧 Installing SharkOS to USB device..."
	@read -p "Enter USB device path (e.g., /dev/sdb): " USB_DEVICE; \
	if [ -b "$$USB_DEVICE" ]; then \
		sudo dd if=$(SHARKOS_IMG) of=$$USB_DEVICE bs=1M status=progress; \
		echo "✅ SharkOS installed to $$USB_DEVICE"; \
	else \
		echo "❌ Invalid device path: $$USB_DEVICE"; \
		exit 1; \
	fi

.PHONY: package
package: all
	@echo "🔧 Creating distribution package..."
	@tar -czf $(BUILD_DIR)/sharkos-$(shell date +%Y%m%d).tar.gz \
		$(BOOTLOADER_DIR) $(KERNEL_DIR) $(BUILD_DIR)/*.bin $(BUILD_DIR)/*.img Makefile README.md
	@echo "✅ Package created: $(BUILD_DIR)/sharkos-$(shell date +%Y%m%d).tar.gz"

# =============================================================================
# Documentation and Help
# =============================================================================

.PHONY: help
help:
	@echo "🦈 SharkOS Build System - Available Targets:"
	@echo ""
	@echo "  🔧 Build Targets:"
	@echo "    all            - Build complete SharkOS (default)"
	@echo "    bootloader     - Build bootloader only"
	@echo "    kernel         - Build kernel only"
	@echo "    disk-image     - Create bootable disk image"
	@echo "    kernel-stub    - Generate basic kernel stub"
	@echo ""
	@echo "  🧪 Testing Targets:"
	@echo "    test           - Run in QEMU"
	@echo "    test-debug     - Run in QEMU with debugging"
	@echo "    test-kvm       - Run in QEMU with KVM acceleration"
	@echo "    test-bochs     - Run in Bochs emulator"
	@echo ""
	@echo "  🔍 Analysis Targets:"
	@echo "    analyze        - Show binary analysis"
	@echo "    disasm-bootloader - Disassemble bootloader"
	@echo "    disasm-kernel  - Disassemble kernel"
	@echo "    verify-boot-signature - Check boot signature"
	@echo ""
	@echo "  📦 Distribution Targets:"
	@echo "    install        - Install to USB device"
	@echo "    package        - Create distribution package"
	@echo ""
	@echo "  🧹 Maintenance Targets:"
	@echo "    clean          - Remove build artifacts"
	@echo "    clean-all      - Remove all generated files"
	@echo "    help           - Show this help message"

.PHONY: info
info:
	@echo "🦈 SharkOS Project Information:"
	@echo "  Project:     SharkOS - AI-Collaborative Operating System"
	@echo "  Version:     0.1.0 (Alpha)"
	@echo "  Architecture: x86-64"
	@echo "  Bootloader:  Custom 64-bit UEFI-compatible"
	@echo "  Kernel:      Monolithic C kernel"
	@echo "  Developed by: Multiple AI Assistants (Claude, ChatGPT, DeepSeek, Copilot)"
	@echo ""
	@echo "🔧 Build Configuration:"
	@echo "  Assembler:   $(ASM)"
	@echo "  Compiler:    $(CC)"
	@echo "  Linker:      $(LD)"
	@echo "  Emulator:    $(QEMU)"
	@echo ""
	@echo "📁 Project Structure:"
	@echo "  $(BOOTLOADER_DIR)/   - Bootloader source files"
	@echo "  $(KERNEL_DIR)/       - Kernel source files"
	@echo "  $(BUILD_DIR)/        - Build output directory"
	@echo "  $(TOOLS_DIR)/        - Development tools"

# =============================================================================
# Cleanup Targets
# =============================================================================

.PHONY: clean
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -f $(BUILD_DIR)/*.bin $(BUILD_DIR)/*.o $(BUILD_DIR)/*.img
	@echo "✅ Build artifacts cleaned"

.PHONY: clean-all
clean-all:
	@echo "🧹 Cleaning all generated files..."
	@rm -rf $(BUILD_DIR) $(TOOLS_DIR)
	@echo "✅ All generated files cleaned"

# =============================================================================
# Development Tools
# =============================================================================

.PHONY: setup-dev
setup-dev:
	@echo "🔧 Setting up development environment..."
	@echo "Installing required packages..."
	@if command -v apt-get >/dev/null 2>&1; then \
		sudo apt-get update && sudo apt-get install -y nasm gcc qemu-system-x86 bochs hexdump; \
	elif command -v yum >/dev/null 2>&1; then \
		sudo yum install -y nasm gcc qemu-system-x86 bochs; \
	elif command -v pacman >/dev/null 2>&1; then \
		sudo pacman -S nasm gcc qemu-system-x86 bochs; \
	else \
		echo "Please install: nasm, gcc, qemu-system-x86, bochs manually"; \
	fi
	@echo "✅ Development environment setup complete"

.PHONY: check-deps
check-deps:
	@echo "🔍 Checking dependencies..."
	@command -v $(ASM) >/dev/null 2>&1 || echo "❌ $(ASM) not found"
	@command -v $(CC) >/dev/null 2>&1 || echo "❌ $(CC) not found"
	@command -v $(LD) >/dev/null 2>&1 || echo "❌ $(LD) not found"
	@command -v $(QEMU) >/dev/null 2>&1 || echo "❌ $(QEMU) not found"
	@echo "✅ Dependency check complete"

# =============================================================================
# Special Targets
# =============================================================================

.PHONY: demo
demo: all
	@echo "🦈 SharkOS Demo Mode - Launching with animation..."
	@echo "   Watch for the SHARK animation during boot!"
	@$(QEMU) -drive format=raw,file=$(SHARKOS_IMG) -m 512M -cpu qemu64 -boot order=c

# Prevent deletion of intermediate files
.PRECIOUS: $(BUILD_DIR)/%.o $(STAGE1_BIN) $(STAGE2_BIN)

# =============================================================================
# End of Makefile
# =============================================================================
