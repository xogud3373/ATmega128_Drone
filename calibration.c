#include <mega128.h>
#include <delay.h>

unsigned int i = 0;
unsigned int j = 0;

/*
// 500us : 921 / 1500us : 2762 / 2500us : 4607
// 1ms : 1843
// 2ms : 3690
*/
                           
void Init_Timer1(void)
{ 
  // COM1A1 : OC1AÇÉ Ãâ·Â(PB5) , WGM12~WGM10 : Fast PWM(TOP = ICR1)
  // COM1B1 : OC1BÇÉ Ãâ·Â(PB6)     
//  TCCR1A |= (1<<COM1A1)|(1<<COM1B1)|(1<<WGM11);           
//  TCCR1B |= (1<<WGM13)|(1<<WGM12)|(1<<CS11);  // 8ºÐÁÖ => 14.7456MHz / 8 = 0.542us = 1.8432MHz
//  TIMSK |= (1<< OCIE1A) | (1<< OCIE1B) | (1<<TOIE1); // compare match interrupt set, overflow interrupt
  
    TCCR1A |= (1<<COM1A1)|(1<<COM1B1)|(1<<WGM11) | (1<<COM1C1);           
    TCCR1B |= (1<<WGM13)|(1<<WGM12)|(1<<CS11);  // 8ºÐÁÖ => 14.7456MHz / 8 = 0.542us = 1.8432MHz
    TIMSK =  (1<<TOIE1); // compare match interrupt set, overflow interrupt
    //ETIMSK |= (1<< OCIE1C);
  
    TCNT1 = 0x00;
    ICR1 = 36864;  // TOP°ª  20000us = 20ms
  
    OCR1A = 3690;
    OCR1B = 3690;
    OCR1CH = 3690 >> 8;
    OCR1CL = 3690 & 0xff;      
}

void Init_Timer3(void)
{
    // COM3A1 : OC3AÇÉ Ãâ·Â(PE3) , WGM33~WGM30 : Fast PWM(TOP = ICR1)
    // COM3B1 : OC3BÇÉ Ãâ·Â(PE4)
    
    TCCR3A |= (1<< COM3B1)| (1<<WGM31);  // | (1<< COM3B1) (1<< COM3A1)
    TCCR3B |= (1<< WGM33)| (1<< WGM32)|(1<<CS31);
    ETIMSK = (1<< TOIE3); // | (1<< OCIE3B); (1<< OCIE3A)
    
    TCNT3H = 0x00;
    TCNT3L = 0x00;
    
    ICR3H = 36864 >> 8;
    ICR3L = 36864 & 0xFF;
    
    OCR3BH = 3690 >> 8;
    OCR3BL = 3690 & 0xff;
    
         
//    TCCR3A |= (1<< COM3A1)| (1<< COM3B1)| (1<<WGM31);
//    TCCR3B |= (1<< WGM33)| (1<< WGM32)|(1<<CS31);
//    ETIMSK |= (1<< OCIE3A) | (1<< OCIE3B) | (1<< TOIE3);
//    
//    ICR3H = 36864 >> 8;
//    ICR3L = 36864 & 0xFF;
//    
//    OCR3AH = 3690 >> 8;
//    OCR3AL = 3690 & 0xff;
//    
//    OCR3BH = 3690 >> 8;
//    OCR3BL = 3690 & 0xff;
}

interrupt [TIM1_OVF] void tim1_overflow(void)
{
    if(i >= 250)
    {
        OCR1A = 1843;
        OCR1B = 1843;
        OCR1CH = 1843 >> 8;
        OCR1CL = 1843 & 0xff;
        i = 0;
    }
    
    i = i + 1;
}


interrupt [TIM3_OVF] void tim3_overflow(void)
{
    if(j >= 250)
    {       
    
        OCR3BH = 1843 >> 8;
        OCR3BL = 1843 & 0xff;
        j = 0;
    }
    j = j + 1;
}

//interrupt [TIM1_COMPA] void tim1_compareA(void)
//{
//}
//interrupt [TIM1_COMPB] void tim1_compareB(void)
//{
//}
//interrupt [TIM1_COMPC] void tim1_compareC(void)
//{
//}
//interrupt [TIM3_COMPA] void tim3_compareA(void)
//{
//}

void Port_Init(void)
{
    DDRB = 0xff;
    DDRE = 0xff;
    PORTE = 0x00;
    PORTB = 0xff;
}

void main(void)
{
    Port_Init();
   
    Init_Timer1();
    Init_Timer3();
    SREG |= 0x80; 
    
    while(1)
    {             
    }
}