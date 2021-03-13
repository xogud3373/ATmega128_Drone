#include <mega128.h>
#include <delay.h>
#include <stdlib.h> 
#include <stdio.h>

unsigned int i = 0;
unsigned int j = 0;
unsigned int p_count = 0;
unsigned char msg[10] = {0,};
unsigned char msg1[10] = {0,};

volatile long int cnt_rising= 0;
volatile long int cnt_falling= 0;
volatile long int throttle= 0;    // 메모리 변수 선언 (인터럽트에서 쓰이는 변수들)

/*
// 500us : 921
// 1500us : 2762
// 2500us : 4607
// 1ms : 1843
// 2ms : 3690
*/


// 동작범위
// 모터구동 1.1ms(OCR 16220) 이상부터 구동됨.
// 송신기 송신 주기 = 14.8ms, 최저 값 = 1.0865ms(OCR = 16020), 최대 값 = 1.915ms (OCR =  28237)




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

// 인터럽트 루틴에서의 데이터 수신
interrupt [USART1_RXC] void usart1_receive(void)    // USART1 RX Complete Handler 
{   
    unsigned char buff;
    buff = UDR1;                                    // UDR1을 buff 버퍼에 저장한다.
    
    if(buff == 'p')
    {
        p_count++;
        buff = 0;
    }
      
}




                           
void Init_Timer1(void)
{ 
  // COM1A1 : OC1A핀 출력(PB5) , WGM12~WGM10 : Fast PWM(TOP = ICR1)
  // COM1B1 : OC1B핀 출력(PB6)
  // COM1C1 : OC1C핀 출력(PB7)     
  TCCR1A |= (1<<COM1A1)|(1<<COM1B1)|(1<<WGM11) | (1<<COM1C1);           
  TCCR1B |= (1<<WGM13)|(1<<WGM12)|(1<<CS10);  // 1분주 14.7456MHz 
  //TIMSK =  (1<<TOIE1); // compare match interrupt set, overflow interrupt (1<< OCIE1A) | (1<< OCIE1B)
  //ETIMSK |= (1<< OCIE1C);
  
  TCNT1 = 0x00;
  ICR1 = 36864;  // TOP값  2500us = 2.5ms

//  OCR1A = 1843;
//  OCR1B = 1843;
//  OCR1CH = 1843 >> 8;
//  OCR1CL = 1843 & 0xff;    
}

void Init_Timer3(void)
{
    //// COM3A1 : OC3A핀 출력(PE3) , WGM33~WGM30 : Fast PWM(TOP = ICR1)
    // COM3B1 : OC3B핀 출력(PE4)     
    TCCR3A |= (1<< COM3B1)| (1<<WGM31);  // | (1<< COM3B1) (1<< COM3A1)
    TCCR3B |= (1<< WGM33)| (1<< WGM32)|(1<<CS30);   // 1분주 14.7456MHz
    //ETIMSK =  (1<< TOIE3); // | (1<< OCIE3B); (1<< OCIE3A)
    
    TCNT3H = 0x00;
    TCNT3L = 0x00;
    
    ICR3H = 36864 >> 8;
    ICR3L = 36864 & 0xFF;
    //ICR3H = 4608 >> 8;
    //ICR3L = 4608 & 0xFF;
    
//    OCR3BH = 1843 >> 8;
//    OCR3BL = 1843 & 0xff;
    
}

interrupt [EXT_INT5] void ext_int5_isr(void)
{
      if(PINE.5 == 1)                         // 상승엣지
      {                                       
             cnt_rising = TCNT1;              // TCNT1 카운터값 read
      }
      else
      {
             cnt_falling = TCNT1;             // TCNT1 카운터값 read

             throttle = (36865- cnt_rising + cnt_falling) % 36865;
      }
 
}


void Interrupt_Init(void)
{
    EIMSK = 0b00100000;
    EICRB = 0b00000100; 
}


void Port_Init(void)
{
    DDRB = 0xFF;
    DDRE = 0xDF;   // 0b1101 1111
    PORTE = 0x00;  // 0b0000 0000
    PORTB = 0xFF;
}

void main(void)
{
    //SREG |= 0x80;
    Init_USART1_IntCon();
    Port_Init();
    Init_Timer3();      
    Init_Timer1();  
    Interrupt_Init();
    
    throttle = 0;     // main문 진입시 초기화할 때, 인터럽트가 발생되는 것을 초기화(왜 되는지는 모름..)
    
    while(throttle < 17000){} // 송신기로 조금 움직이면(1.1ms 이상) 그 때부터 ESC 동작활성화
    OCR1A = 16020;
    OCR1B = 16020;
        
    OCR1CH = 16020 >> 8;
    OCR1CL = 16020 & 0xff;
        
    OCR3BH = 16020 >> 8;
    OCR3BL = 16020 & 0xff;
    delay_ms(3000);
     
    while(1)
    {
    
        OCR1A = throttle;
        OCR1B = throttle;
        
        OCR1CH = throttle >> 8;
        OCR1CL = throttle & 0xff;
        
        OCR3BH = throttle >> 8;
        OCR3BL = throttle & 0xff; 
        
        sprintf(msg1,"%d \n", throttle); 
        puts_USART1(msg1);   //문자열 msg1출력  
                     
    }
}