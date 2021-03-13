#include <mega128.h>
#include <delay.h>
//#include <stdlib.h> 
//#include <stdio.h>

unsigned int i = 0;
unsigned int j = 0;
unsigned int p_count = 0;
unsigned char msg[10] = {0,};

/*
// 500us : 921
// 1500us : 2762
// 2500us : 4607
// 1ms : 1843
// 2ms : 3690
*/

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

// ���ͷ�Ʈ ��ƾ������ ������ ����
interrupt [USART1_RXC] void usart1_receive(void)    // USART1 RX Complete Handler 
{   
    unsigned char buff;
    buff = UDR1;                                    // UDR1�� buff ���ۿ� �����Ѵ�.
    
    if(buff == 'p')
    {
        p_count++;
        buff = 0;
    }
      
}




                           
void Init_Timer1(void)
{ 
  // COM1A1 : OC1A�� ���(PB5) , WGM12~WGM10 : Fast PWM(TOP = ICR1)
  // COM1B1 : OC1B�� ���(PB6)
  // COM1C1 : OC1C�� ���(PB7)     
  TCCR1A |= (1<<COM1A1)|(1<<COM1B1)|(1<<WGM11) | (1<<COM1C1);           
  TCCR1B |= (1<<WGM13)|(1<<WGM12)|(1<<CS11);  // 8���� => 14.7456MHz / 8 = 0.542us = 1.8432MHz
  TIMSK =  (1<<TOIE1); // compare match interrupt set, overflow interrupt (1<< OCIE1A) | (1<< OCIE1B)
  //ETIMSK |= (1<< OCIE1C);
  
  TCNT1 = 0x00;
  //ICR1 = 36864;  // TOP��  20000us = 20ms
  ICR1 = 4608;  // TOP��  20000us = 20ms
  
  OCR1A = 1843;
  OCR1B = 1843;
  OCR1CH = 1843 >> 8;
  OCR1CL = 1843 & 0xff;    
}

void Init_Timer3(void)
{
    //// COM3A1 : OC3A�� ���(PE3) , WGM33~WGM30 : Fast PWM(TOP = ICR1)
    // COM3B1 : OC3B�� ���(PE4)     
    TCCR3A |= (1<< COM3B1)| (1<<WGM31);  // | (1<< COM3B1) (1<< COM3A1)
    TCCR3B |= (1<< WGM33)| (1<< WGM32)|(1<<CS31);
    ETIMSK =  (1<< TOIE3); // | (1<< OCIE3B); (1<< OCIE3A)
    
    TCNT3H = 0x00;
    TCNT3L = 0x00;
    
//    ICR3H = 36864 >> 8;
//    ICR3L = 36864 & 0xFF;
    ICR3H = 4608 >> 8;
    ICR3L = 4608 & 0xFF;
    
    OCR3BH = 1843 >> 8;
    OCR3BL = 1843 & 0xff;
    
}

interrupt [TIM1_OVF] void tim1_overflow(void)
{
    if(i >= 1200)    // 50hz 5�� 500 , 400hz 3�� 1200
    {
        OCR1A = 2000 + (100*p_count);
        OCR1B = 2000 + (100*p_count);
        
        OCR1CH = (2000 + (100*p_count)) >> 8;
        OCR1CL = (2000 + (100*p_count)) & 0xff;
        i = 0;
    }
    
    i = i + 1;
}


interrupt [TIM3_OVF] void tim3_overflow(void)
{
    if(j >= 1200)
    {
        OCR3BH = (2000 + (100*p_count)) >> 8;
        OCR3BL = (2000 + (100*p_count)) & 0xff;
        
        j = 0;
    }
    j = j + 1;
}


void Port_Init(void)
{
    DDRB = 0xff;
    DDRE = 0xff;
    PORTE = 0x00;
    PORTB = 0xFF;
}

void main(void)
{
    //SREG |= 0x80;
    Init_USART1_IntCon();
    Port_Init();
    Init_Timer3();      
    Init_Timer1();  
    
    while(1)
    {
        sprintf(msg,"%d %d \n", p_count, OCR1A); 
        puts_USART1(msg);   //���ڿ� msg1���             
    }
}