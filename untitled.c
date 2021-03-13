void Init_USART1_IntCon(void)
{
 
    // �� RXCIE1=1(���� ���ͷ�Ʈ �㰡), RXEN0=1(���� �㰡), TXEN0 = 1(�۽� �㰡)
    UCSR1B = (1<<RXCIE1)| (1<<RXEN1)|(1 <<TXEN1); 
    UBRR1H = 0x00;        // �� 115200bps ���� ����Ʈ ����
    UBRR1L = 0x07;        // �� 115200bps ���� ����Ʈ ����           
    SREG  |= 0x80;        // �� ��ü ���ͷ�Ʈ �㰡 
}

void putch_USART1(char data)            // USART1�� 1���� �۽� �Լ�  
{              
    while(!(UCSR1A & (1<<UDRE1)));
    UDR1 = data;    
}
             
void puts_USART1(char *str)        // USART1�� ���ڿ� �۽� �Լ�
{
    while(*str != 0){
        putch_USART1(*str);
        str++;    
    }
}


void Init_USART0_IntCon(void)
{
 
    // �� RXCIE1=1(���� ���ͷ�Ʈ �㰡), RXEN0=1(���� �㰡), TXEN0 = 1(�۽� �㰡)
    UCSR0B = (1<<RXCIE0)| (1<<RXEN0)|(1 <<TXEN0); 
    UBRR0H = 0x00;        // �� 115200bps ���� ����Ʈ ����
    UBRR0L = 0x07;        // �� 115200bps ���� ����Ʈ ����           
    SREG  |= 0x80;        // �� ��ü ���ͷ�Ʈ �㰡 
}

void putch_USART0(char data)            // USART1�� 1���� �۽� �Լ�  
{              
    while(!(UCSR0A & (1<<UDRE0)));
    UDR0 = data;    
}
             
void puts_USART0(char *str)        // USART1�� ���ڿ� �۽� �Լ�
{
    while(*str != 0){
        putch_USART0(*str);
        str++;    
    }
}


interrupt [USART0_RXC] void usart0_receive(void)    // USART1 RX Complete Handler 
{   
    unsigned char buff;
    buff = UDR0;                                    // UDR1�� buff ���ۿ� �����Ѵ�.    
    
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