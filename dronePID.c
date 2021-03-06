#include <mega128.h>
#include <delay.h>
#include <stdlib.h> 
#include <stdio.h>
#include <math.h>

#define TWI_START 0x08 
#define MT_REPEATED_START 0x10 
#define MT_SLAW_ACK 0x18 
#define MT_DATA_ACK 0x28 
#define MT_SLAR_ACK 0x40 
#define MT_DATA_NACK 0x58 

#define SR_SLA_ACK 0x60 
#define SR_STOP 0xA0    
#define SR_DATA_ACK 0x80

#define Over_Time 0.0001389

#define MAX_OCR 3690
#define MIN_OCR 1843

#define ts 20         /// 샘플링 시간 
#define tau 0.05         /// 시정수 


unsigned int i = 0;
unsigned int j = 0;
unsigned int cnt = 0;
unsigned char start_flag = 0;   // 모터 시동 후 모터동작 플래그
unsigned char stop_flag = 0;    // 모터 정지 플래그
unsigned char power_flag = 1;   // 시작하자마자 인터럽트 동작플래그

unsigned char msg[40] = {0,};
unsigned char msg1[40] = {0,};

volatile float alpha = 0.96;
volatile float roll,pitch,yaw = 0;
volatile float las_angle_gx, las_angle_gy, las_angle_gz = 0;
volatile float dt = 0.000;
volatile float baseAcX = 0;
volatile float baseAcY = 0;
volatile float baseAcZ = 0;
volatile float baseGyX = 0;
volatile float baseGyY = 0;
volatile float baseGyZ = 0;


float moterOCR1C;
float moterOCR3B;

// PID variable
float roll_desire_angle = 0;
float roll_prev_angle = 0;
float roll_kp = 5;
float roll_ki = 0;
float roll_kd = 0;
float roll_I_control;
float roll_output;


float pitch_desire_angle = 0;
float pitch_prev_angle = 0;
float pitch_kp = 5;
float pitch_ki = 0;
float pitch_kd = 0;
float pitch_I_control;
float pitch_output;



//float yaw_desire_angle = 0;
//float yaw_prev_angle = 0;
//float yaw_kp = 0;
//float yaw_ki = 0;
//float yaw_kd = 0;
//float yaw_I_control;
//float yaw_output;


/*
// 500us : 921
// 1500us : 2762
// 2500us : 4607
// 1ms : 1843
// 2ms : 3690
*/


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


//MPU9250 내부레지스터 주소
enum MPU9250_REG_ADDRESS
{
    DEVICE_ID = 0xD0,
    GYRO_CONFIG = 0x1B,
    ACCEL_CONFIG = 0x1C,
    ACCEL_CONFIG_2 = 0x1D,
    A_XOUT_H = 0x3b,
    A_XOUT_L = 0x3c,
    A_YOUT_H = 0x3d,
    A_YOUT_L = 0x3e,
    A_ZOUT_H = 0x3f,
    A_ZOUT_L = 0x40,
    G_XOUT_H = 0x43,
    G_XOUT_L = 0x44,
    G_YOUT_H = 0x45,
    G_YOUT_L = 0x46,
    G_ZOUT_H = 0x47,
    G_ZOUT_L = 0x48,
    SIGNAL_PATH_RESET = 0x68,
    USER_CTRL = 0x6A,
    PWR_MGMT_1 = 0x6B,
    PWR_MGMT_2 = 0x6C
};

void Init_TWI()
{
    TWBR = 10;        //SCL = 100kHz, 14.7456MHz
    TWCR = (1<<TWEN);   //TWI Enable
    TWSR = 0x00;        //100kHz
}


// TWI통신의 데이터를 읽는  함수.
unsigned char TWI_Read(unsigned char regAddr) 
{ 
    unsigned char Data; 
    TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTA));  //Start조건 전송 
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=TWI_START));  
     
    TWDR = DEVICE_ID&(~0x01);                       //쓰기 위한 주소 전송 
    TWCR = ((1<<TWINT)|(1<<TWEN)); 
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_SLAW_ACK)); 
     
    TWDR = regAddr;                            //Register 주소 전송 
    TWCR = ((1<<TWINT)|(1<<TWEN)); 
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_ACK));
     
    TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTA));  //Restart 전송 
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_REPEATED_START)); 
    
    TWDR = DEVICE_ID|0x01;                          //읽기 위한 주소 전송  
    TWCR = ((1<<TWINT)|(1<<TWEN)); 
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_SLAR_ACK)); 
                                     
     
    TWCR = ((1<<TWINT)|(1<<TWEN));                 
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_NACK));
    Data = TWDR;                        //Data읽기 
      
    TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTO)); 
      
    return Data;     
}


// TWI통신의 데이터를 보내는 함수.
void TWI_Write(unsigned char addr, unsigned char data)
{ 
      
     TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTA));      //Start조건 전송 
     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=TWI_START));  
      
     TWDR = DEVICE_ID&(~0x01); 
     TWCR = ((1<<TWINT)|(1<<TWEN));                 //쓰기 위한 주소 전송 
     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_SLAW_ACK));  
      
     TWDR = addr; 
     TWCR = ((1<<TWINT)|(1<<TWEN));                 //Register 주소 전송
     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_ACK));
     
     TWDR = data;
     TWCR = ((1<<TWINT)|(1<<TWEN));                 //Data쓰기
     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_ACK));
      
     TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTO)); 
}  


void MPU9250_Init(void)
{
    TWI_Write(PWR_MGMT_1, 0x80); // H_RESET[7] : 레지스터 초기화, 디폴트값 회복
    delay_ms(1);                 // MPU9250 RESET delay 1ms 이상 필수
    
    TWI_Write(SIGNAL_PATH_RESET, 0x06); // Reset gyro,accel digital signal path 
    TWI_Write(USER_CTRL, 0x01);  // Reset all the sensor registers
    TWI_Write(GYRO_CONFIG, 0x00); // +250dps
    TWI_Write(ACCEL_CONFIG, 0x00);  // 2g
    TWI_Write(PWR_MGMT_2, 0x00);  // On gyro, accel sensor
    
}

// 가속도센서 출력값 읽기 함수
void Get_Accel_Data(int *acc_x, int *acc_y, int *acc_z)
{
    unsigned char dat[6];
    dat[0] = TWI_Read(A_XOUT_H);
    delay_us(10);
    dat[1] = TWI_Read(A_XOUT_L);
    delay_us(10);
    dat[2] = TWI_Read(A_YOUT_H);
    delay_us(10);
    dat[3] = TWI_Read(A_YOUT_L);
    delay_us(10);
    dat[4] = TWI_Read(A_ZOUT_H);
    delay_us(10);
    dat[5] = TWI_Read(A_ZOUT_L);
    delay_us(10);
    
    *acc_x = dat[0] << 8 | dat[1];
    *acc_y = dat[2] << 8 | dat[3];
    *acc_z = dat[4] << 8 | dat[5];
}


// 자이로센서 출력값 읽기 함수
void Get_Gyro_Data(int *gyro_x, int *gyro_y, int *gyro_z)
{
    unsigned char dat[6];
    dat[0] = TWI_Read(G_XOUT_H);
    delay_us(10);
    dat[1] = TWI_Read(G_XOUT_L);
    delay_us(10);
    dat[2] = TWI_Read(G_YOUT_H);
    delay_us(10);
    dat[3] = TWI_Read(G_YOUT_L);
    delay_us(10);
    dat[4] = TWI_Read(G_ZOUT_H);
    delay_us(10);
    dat[5] = TWI_Read(G_ZOUT_L);
    delay_us(10);
    
    *gyro_x = dat[0] << 8 | dat[1];
    *gyro_y = dat[2] << 8 | dat[3];
    *gyro_z = dat[4] << 8 | dat[5];
}

// IMU초기값 설정을 위한 캘리브레이션 함수
void Calibrate_IMU(int *acc_x, int *acc_y, int *acc_z, int *gyro_x, int *gyro_y, int *gyro_z)
{
    int i = 0;
    int sumAcX = 0, sumAcY = 0, sumAcZ = 0;
    int sumGyX = 0, sumGyY = 0, sumGyZ = 0;
    
    for(i = 0; i<10; i++)
    {
        Get_Accel_Data(acc_x, acc_y, acc_z);
        Get_Gyro_Data(gyro_x, gyro_y, gyro_z);
        sumAcX += acc_x; sumAcY += acc_y; sumAcZ += acc_z;
        sumGyX += gyro_x; sumGyY += gyro_y; sumGyZ += gyro_z;
        delay_ms(100);        
    }
    
    baseAcX = sumAcX / 10;
    baseAcY = sumAcY / 10;
    baseAcZ = sumAcZ / 10;
    baseGyX = sumGyX / 10;
    baseGyY = sumGyY / 10;
    baseGyZ = sumGyZ / 10;
}


/**
  *@brief MPU9250 측정값 -> 가속도 변환 함수
  *@param a_x : x축 가속도 값을 g단위로 저장하여 저장할 변수의 참조 값
  *@param a_y : y축 가속도 값을 g단위로 저장하여 저장할 변수의 참조 값
  *@param a_z : z축 가속도 값을 g단위로 저장하여 저장할 변수의 참조 값
  *@param acc_x : 관성센서로 측정된 x축 가속도의 측정값
  *@param acc_y : 관성센서로 측정된 y축 가속도의 측정값
  *@param acc_z : 관성센서로 측정된 z축 가속도의 측정값
  */
void Conv_Value_Acc(float *a_x, float *a_y, float *a_z, int acc_x, int acc_y, int acc_z)
{
    
    *a_x = (float)acc_x/16384; //가속도 g단위 변환
    *a_y = (float)acc_y/16384;
    *a_z = (float)acc_z/16384;
}


/**
  *@brief MPU9250 측정값 -> 가각속도 변환 함수
  *@param g_x : x축 각속도 값을 DPG단위로 저장하여 저장할 변수의 참조 값
  *@param g_y : y축 각속도 값을 DPG단위로 저장하여 저장할 변수의 참조 값
  *@param g_z : z축 각속도 값을 DPG단위로 저장하여 저장할 변수의 참조 값
  *@param gyro_x : 관성센서로 측정된 x축 각속도의 측정값
  *@param gyro_y : 관성센서로 측정된 y축 각속도의 측정값
  *@param gyro_z : 관성센서로 측정된 z축 각속도의 측정값
  */
void Conv_Value_Gyro(float *g_x, float *g_y, float *g_z, int gyro_x, int gyro_y, int gyro_z)
{
    *g_x = (float)(gyro_x - baseGyX) / 131; //각속도 변환
    *g_y = (float)(gyro_y - baseGyY) / 131;
    *g_z = (float)(gyro_z - baseGyZ) / 131;
}


// IMU dt값 구하기 위한 타이머초기화
void Timer_Init_IMU(void)
{
    TCCR0 = (1<<CS01);     // Normal 모드, 14.7456MHz 256분주 , 0.0576MHz
                           // while문 도는데 12ms 정도 걸려서 2ms 마다 dt값 증가
    TCNT0 = 0;
    TIMSK = (1<<TOIE0);              
}


// 드론 모터 타이머                           
void Init_Timer1_BLDC(void)
{ 
  // COM1A1 : OC1A핀 출력(PB5) , WGM12~WGM10 : Fast PWM(TOP = ICR1)
  // COM1B1 : OC1B핀 출력(PB6)
  // COM1C1 : OC1C핀 출력(PB7)     
  TCCR1A |= (1<<COM1A1)|(1<<COM1B1)|(1<<WGM11) | (1<<COM1C1);           
  TCCR1B |= (1<<WGM13)|(1<<WGM12)|(1<<CS11);  // 8분주 => 14.7456MHz / 8 = 0.542us = 1.8432MHz
  TIMSK =  (1<<TOIE1); // compare match interrupt set, overflow interrupt (1<< OCIE1A) | (1<< OCIE1B)
  //ETIMSK |= (1<< OCIE1C);
  
  TCNT1 = 0x00;
  ICR1 = 36864;  // TOP값  20000us = 20ms
  
  OCR1A = 1843;
  OCR1B = 1843;
  OCR1CH = 1843 >> 8;
  OCR1CL = 1843 & 0xff;    
}


// 드론 모터 타이머
void Init_Timer3_BLDC(void)
{
    //// COM3A1 : OC3A핀 출력(PE3) , WGM33~WGM30 : Fast PWM(TOP = ICR1)
    // COM3B1 : OC3B핀 출력(PE4)     
    TCCR3A |= (1<< COM3B1)| (1<<WGM31);  // | (1<< COM3B1) (1<< COM3A1)
    TCCR3B |= (1<< WGM33)| (1<< WGM32)|(1<<CS31);
    ETIMSK =  (1<< TOIE3); // | (1<< OCIE3B); (1<< OCIE3A)
    
    TCNT3H = 0x00;
    TCNT3L = 0x00;
    
    ICR3H = 36864 >> 8;
    ICR3L = 36864 & 0xFF;
    
    OCR3BH = 1843 >> 8;
    OCR3BL = 1843 & 0xff;
    
}


// dt값 계산을 위한 카운터값 증가
interrupt [TIM0_OVF] void overflow(void)
{
    cnt++;
}


// 드론모터 => 10초뒤 원하는 OCR값으로 변경
interrupt [TIM1_OVF] void tim1_overflow(void)
{
    if(power_flag)
    {
        if(i >= 500)
        {   
            start_flag = 1; 
            if(i >= 3000)
            {     
                stop_flag = 1;
                start_flag = 0;
                power_flag = 0;
                i = 0;
            }        
              
        }
        
        i = i + 1;
    }
}



// 드론모터 => 10초뒤 원하는 OCR값으로 변경
interrupt [TIM3_OVF] void tim3_overflow(void)
{
    if(power_flag)
    {
        if(j >= 500)
        {   
            start_flag = 1; 
            if(j >= 3000)
            {
                stop_flag = 1;
                start_flag = 0;
                power_flag = 0;
                j = 0;
            }
              
        }
        
        j = j + 1;
    }
}


void Lowpass_filter(float *range, float *pre_range, float *now_range)
{
    *range = (tau * (*pre_range) + ((float)ts/1000) * (*now_range)) / (tau +((float)ts/1000)) ;
}


// PID함수
void StdPID(float *desire, float *current_angle, float *prev_angle, float *I_control, float *Kp, float *Ki, float *Kd, float *PID_control)
{
    float error;
    float dInput;
    float P_control;
    float D_control;
    
    error = *desire - *current_angle;        // 에러값 
    dInput = *current_angle - *prev_angle;
    *prev_angle = *current_angle;
    
    P_control = (*Kp) * error;
    *I_control += (*Ki) * (error * dt);
    D_control = -(*Kd) * (dInput/ dt);
    
    *PID_control = P_control + *I_control + D_control;  // PID 출력
        
}

void CalcMotorPID()
{
    StdPID(&roll_desire_angle, &roll, &roll_prev_angle, &roll_I_control, &roll_kp, &roll_ki, &roll_kd, &roll_output);
    StdPID(&pitch_desire_angle, &pitch, &pitch_prev_angle, &pitch_I_control, &pitch_kp, &pitch_ki, &pitch_kd, &pitch_output);
    //StdPID(&yaw_desire_angle, &yaw, &yaw_prev_angle, &yaw_kp, &yaw_ki, &yaw_kd, &yaw_I_control, &yaw_output);
  
}


void MotorSpeed()
{

//    int OCR1CW;
//    int OCR3BW;
    
//    OCR1A = 2200 + roll_output - pitch_output;
//    OCR1B = 2200 + roll_output + pitch_output;
//    
//    moterOCR1C = (2200 - roll_output + pitch_output);
//    moterOCR3B = (2200 - roll_output - pitch_output);
//    
//    OCR1CH = (int)(moterOCR1C) >> 8;
//    OCR1CL = (int)(moterOCR1C) & 0xff;
//    
//    OCR3BH = (int)moterOCR3B >> 8;
//    OCR3BL = (int)moterOCR3B & 0xff;

    OCR1A = 2300 - roll_output + pitch_output;
    moterOCR3B = (2300 + roll_output + pitch_output);
    
    OCR1B = 2300 - roll_output - pitch_output;
    moterOCR1C = (2300 + roll_output - pitch_output);
    
    OCR1CH = (int)(moterOCR1C) >> 8;
    OCR1CL = (int)(moterOCR1C) & 0xff;
    
    OCR3BH = (int)moterOCR3B >> 8;
    OCR3BL = (int)moterOCR3B & 0xff;

    
//    OCR1CW = (OCR1CH << 8)|(OCR1CL);
//    OCR3BW = (OCR3BH << 8)|(OCR3BL);
    
//    
//    if(OCR1A > MAX_OCR) OCR1A = MAX_OCR;
//    if(OCR1A < MIN_OCR) OCR1A = MIN_OCR;
//    
//    if(OCR1B > MAX_OCR) OCR1B = MAX_OCR;
//    if(OCR1B < MIN_OCR) OCR1B = MIN_OCR;
//    
//    if(OCR1CW > MAX_OCR)
//    {
//        OCR1CH = MAX_OCR >> 8;
//        OCR1CL = MAX_OCR & 0xff;
//    }
//    
//    if(OCR1CW < MIN_OCR)
//    {
//        OCR1CH = MIN_OCR >> 8;
//        OCR1CL = MIN_OCR & 0xff;
//    }
//    
//    if(OCR3BW > MAX_OCR)
//    {
//        OCR3BH = MAX_OCR >> 8;
//        OCR3BL = MAX_OCR & 0xff;
//    }
//    
//    if(OCR3BW < MIN_OCR)
//    {
//        OCR3BH = MIN_OCR >> 8;
//        OCR3BL = MIN_OCR & 0xff;
//    }
    
     
}

void MotorStop()
{
    
    OCR1A = MIN_OCR;
    OCR1B = MIN_OCR;
    
    OCR1CH = MIN_OCR >> 8;
    OCR1CL = MIN_OCR & 0xff;
    
    OCR3BH = MIN_OCR >> 8;
    OCR3BL = MIN_OCR & 0xff;
        
}



// 포트초기화
void Port_Init(void)
{
    DDRB = 0xff;
    DDRE = 0xff;
    PORTE = 0x00;
    PORTB = 0xFF;
}

void main(void)
{
    // 가속도, 자이로센서 x,y,z 출력값
    int acc_x = 0, acc_y = 0, acc_z = 0;
    int gyro_x = 0, gyro_y = 0, gyro_z = 0; 
    
    // 가속도센서 = 중력가속도(16384)를 기준 1로 잡음
    // 자이로센서 = gyro_config(+-250rad/sec = +-16384)로 설정되어 있을 때,
    // 1rad/sec = (16384 * 2) / 250 = 각속도 / 131
    float a_x = 0, a_y = 0, a_z = 0;
    float g_x = 0, g_y = 0, g_z = 0;
    
    float angle_ax = 0, angle_ay = 0;
    float angle_gx = 0, angle_gy = 0, angle_gz = 0;

    
    Init_USART1_IntCon();
    Init_TWI();
    MPU9250_Init(); 
    Timer_Init_IMU();
    Calibrate_IMU(&acc_x, &acc_y, &acc_z, &gyro_x, &gyro_y, &gyro_z);
    
    Port_Init();
    Init_Timer3_BLDC();      
    Init_Timer1_BLDC();  
    
    while(1)
    {
        //이전 자이로 각도 - 상보필터를 걸쳐서 나온 값
        las_angle_gx = roll;                                                                                                                            
        las_angle_gy = pitch;
        las_angle_gz = yaw;
            
        Get_Accel_Data(&acc_x,&acc_y,&acc_z);
        Get_Gyro_Data(&gyro_x, &gyro_y, &gyro_z);  
        
        dt = Over_Time * cnt;  
        
        cnt = 0;
        
        Conv_Value_Acc(&a_x, &a_y, &a_z, acc_x, acc_y, acc_z);
        Conv_Value_Gyro(&g_x, &g_y, &g_z, gyro_x, gyro_y, gyro_z);
        
        angle_ax = atan(a_y/a_z)*180/PI;      // x축 각도 값 
        angle_ay = atan(a_x/a_z)*180/PI;      // y축 각도 값 
        
        angle_gx = g_x * dt + las_angle_gx;   // 자이로센서 출력값 적분
        angle_gy = g_y * dt + las_angle_gy;
        angle_gz = g_z * dt + las_angle_gz;
         
        
        
        // 상보필터 적용
        roll = alpha* angle_gx + (1.000 - alpha)*angle_ax;      
        pitch = alpha* angle_gy + (1.000 - alpha)*angle_ay;
        yaw = angle_gz;
        
        if(start_flag)
        {
            CalcMotorPID();
            MotorSpeed();
            
        }
        if(stop_flag)
        {
            MotorStop();
            
        }
        
        dt = 0.000;                           // dt 초기화
        
//        sprintf(msg,"Roll : %.3f Pitch : %.3f \n", roll_output, pitch_output); 
//        puts_USART1(msg);   //문자열 msg1출력
//        sprintf(msg1,"roll_deg : %.3f pitch_deg : %.3f \n", roll, pitch); 
//        puts_USART1(msg1);   //문자열 msg1출력
//        sprintf(msg1,"OCR1A : %d OCR1B : %d OCR1C : %d OCR3B : %d \n", OCR1A, OCR1B, moterOCR1C, moterOCR3B); 
//        puts_USART1(msg1);   //문자열 msg1출력
                     
    }
}