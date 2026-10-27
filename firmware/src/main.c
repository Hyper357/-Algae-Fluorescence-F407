#include "stm32f4xx_hal.h"

/* Candidate configuration for offline compilation only. Confirm the board's
 * MCU, USART1 routing and jumper positions before programming any device. */
int main(void) {
    UART_HandleTypeDef uart = {0};
    GPIO_InitTypeDef pins = {0};
    static const uint8_t message[] = "F407_BOOT,unverified_board,g0-0.1\r\n";

    if (HAL_Init() != HAL_OK) { /* Reset clock remains HSI, nominally 16 MHz. */
        for (;;) { }
    }
    __HAL_RCC_GPIOA_CLK_ENABLE();
    __HAL_RCC_USART1_CLK_ENABLE();
    pins.Pin = GPIO_PIN_9 | GPIO_PIN_10;
    pins.Mode = GPIO_MODE_AF_PP;
    pins.Pull = GPIO_PULLUP;
    pins.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
    pins.Alternate = GPIO_AF7_USART1;
    HAL_GPIO_Init(GPIOA, &pins);

    uart.Instance = USART1;
    uart.Init.BaudRate = 115200;
    uart.Init.WordLength = UART_WORDLENGTH_8B;
    uart.Init.StopBits = UART_STOPBITS_1;
    uart.Init.Parity = UART_PARITY_NONE;
    uart.Init.Mode = UART_MODE_TX_RX;
    uart.Init.HwFlowCtl = UART_HWCONTROL_NONE;
    uart.Init.OverSampling = UART_OVERSAMPLING_16;
    if (HAL_UART_Init(&uart) != HAL_OK) {
        for (;;) { }
    }
    (void)HAL_UART_Transmit(&uart, message, sizeof(message) - 1U, 1000U);
    for (;;) { HAL_Delay(1000U); }
}
