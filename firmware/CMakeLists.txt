cmake_minimum_required(VERSION 3.20)
project(f407_g0 LANGUAGES C ASM)

if(NOT DEFINED STM32CUBE_F4_ROOT)
  message(FATAL_ERROR "Set STM32CUBE_F4_ROOT to the pinned STM32CubeF4 checkout")
endif()
set(HAL "${STM32CUBE_F4_ROOT}/Drivers/STM32F4xx_HAL_Driver")
set(CMSIS "${STM32CUBE_F4_ROOT}/Drivers/CMSIS")
set(DEVICE "${CMSIS}/Device/ST/STM32F4xx")
if(NOT EXISTS "${HAL}/Src/stm32f4xx_hal.c" OR NOT EXISTS "${DEVICE}/Include/stm32f407xx.h")
  message(FATAL_ERROR "STM32CubeF4 HAL/CMSIS dependencies are incomplete")
endif()

add_executable(f407_g0.elf
  src/main.c
  src/stm32f4xx_it.c
  "${DEVICE}/Source/Templates/system_stm32f4xx.c"
  "${DEVICE}/Source/Templates/gcc/startup_stm32f407xx.s"
  "${HAL}/Src/stm32f4xx_hal.c"
  "${HAL}/Src/stm32f4xx_hal_cortex.c"
  "${HAL}/Src/stm32f4xx_hal_gpio.c"
  "${HAL}/Src/stm32f4xx_hal_rcc.c"
  "${HAL}/Src/stm32f4xx_hal_uart.c"
)
target_compile_definitions(f407_g0.elf PRIVATE STM32F407xx USE_HAL_DRIVER)
target_include_directories(f407_g0.elf PRIVATE include "${HAL}/Inc" "${CMSIS}/Include" "${DEVICE}/Include")
target_compile_options(f407_g0.elf PRIVATE -mcpu=cortex-m4 -mthumb -mfloat-abi=soft -ffunction-sections -fdata-sections "$<$<COMPILE_LANGUAGE:C>:-Wall;-Wextra>")
target_link_options(f407_g0.elf PRIVATE -mcpu=cortex-m4 -mthumb -mfloat-abi=soft --specs=nano.specs --specs=nosys.specs "-T${CMAKE_CURRENT_SOURCE_DIR}/STM32F407ZG_FLASH.ld" -Wl,--gc-sections "-Wl,-Map=${CMAKE_CURRENT_BINARY_DIR}/f407_g0.map")
set_property(TARGET f407_g0.elf APPEND PROPERTY LINK_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/STM32F407ZG_FLASH.ld")
add_custom_command(TARGET f407_g0.elf POST_BUILD
  COMMAND "${ARM_OBJCOPY}" -O binary $<TARGET_FILE:f407_g0.elf> "${CMAKE_CURRENT_BINARY_DIR}/f407_g0.bin"
  COMMAND "${ARM_SIZE}" $<TARGET_FILE:f407_g0.elf>
  VERBATIM
)
