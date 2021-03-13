void Init_USART1_IntCon(void)
{
 
    // ② RXCIE1=1(수신 인터럽트 허가), RXEN0=1(수신 허가), TXEN0 = 1(송신 허가)
    UCSR1B = (1<<RXCIE1)| (1<<RXEN1)|(1 <<TXEN1); 
    UBRR1H = 0x00;        // ③ 115200bps 보오 레이트 설정
    UBRR1L = 0x07;        // ③ 115200bps 보오 레이트 설정           
    SREG  |= 0x80;        // ① 전체 인터럽트 허가 
}

void putch_USART1(char data)            // USART1용 1문자 송신 함수  
{              
    while(!(UCSR1A & (1<<UDRE1)));
    UDR1 = data;    
}
             
void puts_USART1(char *str)        // USART1용 문자열 송신 함수
{
    while(*str != 0){
        putch_USART1(*str);
        str++;    
    }
}


void Init_USART0_IntCon(void)
{
 
    // ② RXCIE1=1(수신 인터럽트 허가), RXEN0=1(수신 허가), TXEN0 = 1(송신 허가)
    UCSR0B = (1<<RXCIE0)| (1<<RXEN0)|(1 <<TXEN0); 
    UBRR0H = 0x00;        // ③ 115200bps 보오 레이트 설정
    UBRR0L = 0x07;        // ③ 115200bps 보오 레이트 설정           
    SREG  |= 0x80;        // ① 전체 인터럽트 허가 
}

void putch_USART0(char data)            // USART1용 1문자 송신 함수  
{              
    while(!(UCSR0A & (1<<UDRE0)));
    UDR0 = data;    
}
             
void puts_USART0(char *str)        // USART1용 문자열 송신 함수
{
    while(*str != 0){
        putch_USART0(*str);
        str++;    
    }
}


interrupt [USART0_RXC] void usart0_receive(void)    // USART1 RX Complete Handler 
{   
    unsigned char buff;
    buff = UDR0;                                    // UDR1을 buff 버퍼에 저장한다.    
    
    current_str[buffer_count] = buff;
    buffer_count++;   
}

void main(void)
{
    Init_USART1_IntCon();
    Init_USART0_IntCon();
    puts_USART0("ss=4");
    while(1)
    {
        if(current_str[buffer_count] != 0)
        {
            puts_USART1(current_str);
        }
    }
}