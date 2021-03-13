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
//#define ENC_B PINE.5

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

unsigned int cnt1 = 0;

//MPU9250 ���η������� �ּ�
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


void Init_TWI()
{
    TWBR = 10;        //SCL = 100kHz, 14.7456MHz
    TWCR = (1<<TWEN);   //TWI Enable
    TWSR = 0x00;        //100kHz
}


// TWI����� �����͸� �д�  �Լ�.
unsigned char TWI_Read(unsigned char regAddr) 
{ 
    unsigned char Data; 
    TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTA));  //Start���� ���� 
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=TWI_START));  
     
    TWDR = DEVICE_ID&(~0x01);                       //���� ���� �ּ� ���� 
    TWCR = ((1<<TWINT)|(1<<TWEN)); 
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_SLAW_ACK)); 
     
    TWDR = regAddr;                            //Register �ּ� ���� 
    TWCR = ((1<<TWINT)|(1<<TWEN)); 
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_ACK));
     
    TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTA));  //Restart ���� 
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_REPEATED_START)); 
    
    TWDR = DEVICE_ID|0x01;                          //�б� ���� �ּ� ����  
    TWCR = ((1<<TWINT)|(1<<TWEN)); 
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_SLAR_ACK)); 
                                     
     
    TWCR = ((1<<TWINT)|(1<<TWEN));                 
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_NACK));
    Data = TWDR;                        //Data�б� 
      
    TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTO)); 
      
    return Data;     
}

// TWI����� �����͸� ������ �Լ�.
void TWI_Write(unsigned char addr, unsigned char data)
{ 
      
     TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTA));      //Start���� ���� 
     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=TWI_START));  
      
     TWDR = DEVICE_ID&(~0x01); 
     TWCR = ((1<<TWINT)|(1<<TWEN));                 //���� ���� �ּ� ���� 
     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_SLAW_ACK));  
      
     TWDR = addr; 
     TWCR = ((1<<TWINT)|(1<<TWEN));                 //Register �ּ� ����
     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_ACK));
     
     TWDR = data;
     TWCR = ((1<<TWINT)|(1<<TWEN));                 //Data����
     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_ACK));
      
     TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTO)); 
}  


void MPU9250_Init(void)
{
    TWI_Write(PWR_MGMT_1, 0x80); // H_RESET[7] : �������� �ʱ�ȭ, ����Ʈ�� ȸ��
    delay_ms(1);                 // MPU9250 RESET delay 1ms �̻� �ʼ�
    
    TWI_Write(SIGNAL_PATH_RESET, 0x06); // Reset gyro,accel digital signal path 
    TWI_Write(USER_CTRL, 0x01);  // Reset all the sensor registers
    TWI_Write(GYRO_CONFIG, 0x00); // +500dps
    TWI_Write(ACCEL_CONFIG, 0x00);  // 2g
    TWI_Write(PWR_MGMT_2, 0x00);  // On gyro, accel sensor
    
}

// ���ӵ����� ��°� �б� �Լ�
void Get_Accel_Data(int *acc_x, int *acc_y, int *acc_z)
{
    unsigned char dat[6];
    dat[0] = TWI_Read(A_XOUT_H);
    dat[1] = TWI_Read(A_XOUT_L);
    dat[2] = TWI_Read(A_YOUT_H);
    dat[3] = TWI_Read(A_YOUT_L);
    dat[4] = TWI_Read(A_ZOUT_H);
    dat[5] = TWI_Read(A_ZOUT_L);
    
    *acc_x = dat[0] << 8 | dat[1];
    *acc_y = dat[2] << 8 | dat[3];
    *acc_z = dat[4] << 8 | dat[5];
}

// ���̷μ��� ��°� �б� �Լ�
void Get_Gyro_Data(int *gyro_x, int *gyro_y, int *gyro_z)
{
    unsigned char dat[6];
    dat[0] = TWI_Read(G_XOUT_H);
    dat[1] = TWI_Read(G_XOUT_L);
    dat[2] = TWI_Read(G_YOUT_H);
    dat[3] = TWI_Read(G_YOUT_L);
    dat[4] = TWI_Read(G_ZOUT_H);
    dat[5] = TWI_Read(G_ZOUT_L);
    *gyro_x = dat[0] << 8 | dat[1];
    *gyro_y = dat[2] << 8 | dat[3];
    *gyro_z = dat[4] << 8 | dat[5];
}

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
        delay_ms(10);        
    }
    
    baseAcX = sumAcX / 10;
    baseAcY = sumAcY / 10;
    baseAcZ = sumAcZ / 10;
    baseGyX = sumGyX / 10;
    baseGyY = sumGyY / 10;
    baseGyZ = sumGyZ / 10;
}

void Timer_Init(void)
{
    TCCR0 = (1<<CS01);     // Normal ���, 14.7456MHz 256���� , 0.0576MHz
                           // while�� ���µ� 12ms ���� �ɷ��� 2ms ���� dt�� ����
    TCNT0 = 0;
    TIMSK |= (1<<TOIE0);              
}

interrupt [TIM0_OVF] void overflow(void)
{
    cnt1++;
}

/**
  *@brief MPU9250 ������ -> ���ӵ� ��ȯ �Լ�
  *@param a_x : x�� ���ӵ� ���� g������ �����Ͽ� ������ ������ ���� ��
  *@param a_y : y�� ���ӵ� ���� g������ �����Ͽ� ������ ������ ���� ��
  *@param a_z : z�� ���ӵ� ���� g������ �����Ͽ� ������ ������ ���� ��
  *@param acc_x : ���������� ������ x�� ���ӵ��� ������
  *@param acc_y : ���������� ������ y�� ���ӵ��� ������
  *@param acc_z : ���������� ������ z�� ���ӵ��� ������
  */
void Conv_Value_Acc(float *a_x, float *a_y, float *a_z, int acc_x, int acc_y, int acc_z)
{
    
    *a_x = (float)acc_x/16384; //���ӵ� g���� ��ȯ
    *a_y = (float)acc_y/16384;
    *a_z = (float)acc_z/16384;
}

/**
  *@brief MPU9250 ������ -> �����ӵ� ��ȯ �Լ�
  *@param g_x : x�� ���ӵ� ���� DPG������ �����Ͽ� ������ ������ ���� ��
  *@param g_y : y�� ���ӵ� ���� DPG������ �����Ͽ� ������ ������ ���� ��
  *@param g_z : z�� ���ӵ� ���� DPG������ �����Ͽ� ������ ������ ���� ��
  *@param gyro_x : ���������� ������ x�� ���ӵ��� ������
  *@param gyro_y : ���������� ������ y�� ���ӵ��� ������
  *@param gyro_z : ���������� ������ z�� ���ӵ��� ������
  */
void Conv_Value_Gyro(float *g_x, float *g_y, float *g_z, int gyro_x, int gyro_y, int gyro_z)
{
    *g_x = (float)(gyro_x - baseGyX) / 131; //���ӵ� ��ȯ
    *g_y = (float)(gyro_y - baseGyY) / 131;
    *g_z = (float)(gyro_z - baseGyZ) / 131;

//    *g_x = (float)(gyro_x - baseGyX) / 66; //���ӵ� ��ȯ
//    *g_y = (float)(gyro_y - baseGyY) / 66;
//    *g_z = (float)(gyro_z - baseGyZ) / 66;
}

void main(void)
{
    // ���ӵ�, ���̷μ��� x,y,z ��°�
    int acc_x = 0, acc_y = 0, acc_z = 0;
    int gyro_x = 0, gyro_y = 0, gyro_z = 0; 
    
    // ���ӵ����� = �߷°��ӵ�(16384)�� ���� 1�� ����
    // ���̷μ��� = gyro_config(+-250rad/sec = +-16384)�� �����Ǿ� ���� ��,
    // 1rad/sec = (16384 * 2) / 250 = ���ӵ� / 131
    float a_x = 0, a_y = 0, a_z = 0;
    float g_x = 0, g_y = 0, g_z = 0;
    
    float angle_ax = 0, angle_ay = 0;
    float angle_gx = 0, angle_gy = 0, angle_gz = 0;
    char msg[40] = {0,};
    
    DDRE = 0x00;
    
    Init_USART1_IntCon();
    Init_TWI();
    MPU9250_Init(); 
    Timer_Init();
    
    //Calibrate_IMU(&acc_x, &acc_y, &acc_z, &gyro_x, &gyro_y, &gyro_z);
    while(1)
    {   
        //���� ���̷� ���� - �����͸� ���ļ� ���� ��
        las_angle_gx = roll;                                                                                                                            
        las_angle_gy = pitch;
        las_angle_gz = yaw;
            
        Get_Accel_Data(&acc_x,&acc_y,&acc_z);
        Get_Gyro_Data(&gyro_x, &gyro_y, &gyro_z);  
        
        dt = Over_Time * cnt1;  
        
        cnt1 = 0;
        
        Conv_Value_Acc(&a_x, &a_y, &a_z, acc_x, acc_y, acc_z);
        Conv_Value_Gyro(&g_x, &g_y, &g_z, gyro_x, gyro_y, gyro_z);
        
        angle_ax = atan(a_y/a_z)*180/PI;      // x�� ���� �� 
        angle_ay = atan(a_x/a_z)*180/PI;      // y�� ���� �� 
        
        angle_gx = g_x * dt + las_angle_gx;   // ���̷μ��� ��°� ����
        angle_gy = g_y * dt + las_angle_gy;
        angle_gz = g_z * dt + las_angle_gz;
         
        dt = 0.000;                           // dt �ʱ�ȭ
        
        // ������ ����
        roll = alpha* angle_gx + (1.000 - alpha)*angle_ax;      
        pitch = alpha* angle_gy + (1.000 - alpha)*angle_ay;
        yaw = angle_gz;
        
        
        sprintf(msg,"%.3f %.3f %.3f %.3f %.3f %.3f %.3f \n", a_x, a_y, a_z, g_x, g_y, g_z, pitch);  
        puts_USART1(msg);   //���ڿ� msg1���
        
        delay_ms(10);
        
    }
    
}