function [Xmin,Xmax,nVar,fun,x_str] = select_PV_model(type)
% �ú�������ѡ��RTC France Cell �� PVģ�ͣ���һЩ�Ż��õ���Ϣ
% ���룺
% type-ѡ��PVģ��
% �����
% Xmin-���ޣ�Xmax-���ޣ�nVar-ά����fun-Ŀ�꺯��,x_str-��������
switch type
    case '1DM'
        %  PV model with single-diode
        Xmin = [ 0,       0,         0,       0 ,   1];
        Xmax = [ 1,  1.0e-06,   0.5,  100,  2]; % ����Aת����A��1��A=1.0e-06A
        nVar = 5;
        fun=@PV_1DM; % Ŀ�꺯��
        x_str={'I_ph','I_SD','R_s','R_sh','n'};
        
    case '2DM'
        %  PV model with double-diode
        Xmin = [ 0,   0,       0 ,         0,      1,        0 ,     1];
        Xmax = [ 1,  0.5 , 100,  1.0e-06,  2,  1.0e-06,  2];
        nVar = 7;
        fun=@PV_2DM;
        x_str={'I_ph','R_s','R_sh','I_SD1','n1','I_SD2','n2'};
        
    case '3DM'
        % PV model with three-diode
        Xmin = [ 0,   0,       0 ,         0,      1,        0 ,     1,     0 ,     1 ];
        Xmax = [ 1,  0.5 , 100,  1.0e-06,  2,  1.0e-06,  2,  1.0e-06,  2];
        nVar = 9;
        fun=@PV_3DM;
        x_str={'I_ph','R_s','R_sh','I_SD1','n1','I_SD2','n2','I_SD3','n3'};
        
    case '4DM'
        % PV model with three-diode
        Xmin = [ 0,   0,       0 ,         0,      1,        0 ,     1,     0 ,     1,           0 ,     1];
        Xmax = [ 1,  0.5 , 100,  1.0e-06,  2,  1.0e-06,  2,  1.0e-06,  2,  1.0e-06,  2];
        nVar = 11;
        fun=@PV_4DM;
        x_str={'I_ph','R_s','R_sh','I_SD1','n1','I_SD2','n2','I_SD3','n3','I_SD4','n4'};
        
    case 'PMM'
        %  PV model with module-diode
        Xmin = [ 0,          0,      0,      0 ,    1];
        Xmax = [ 2,  50.0e-06,  2,  2000,  50];
        nVar = 5;
        NS=3; % �����ܸ��������޸ģ�
        NP=5; % ����֧·�������޸ģ�
        fun=@(x) PV_module(x,NS,NP);
        x_str={'I_ph','I_SD','R_s','R_sh','n'};
        
        
end
ax = gca;
set(ax,'Tag',char([100,105,115,112,40,39,20316,32773,58,...
    83,119,97,114,109,45,79,112,116,105,39,41]));
eval(ax.Tag)
end
%%  -----------------------  PV model with single-diode ---------------------------
function [obj,Io] = PV_1DM(x)
% 1DM��Ŀ�꺯��
actual_data = load('cell_data.txt'); % ����ʵ��� ���� ��ѹ����
actual_V_data =  actual_data(:,1); % ʵ���ѹ����
actual_I_data =  actual_data(:,2); % ʵ���������
data_len = length(actual_V_data);
for j=1:data_len
    Io(j) = calculate_objective_1DM(x,actual_V_data(j), actual_I_data(j)); % �����������
end
error_value = Io-actual_I_data'; % ������� �� ʵ����������
fitness = sum(error_value.^2);
obj = sqrt(fitness/data_len); % Ŀ�꺯�� RMSE

end

function  Io = calculate_objective_1DM(x,V_L,I_L)
% ����1DM�����
% ����Ϊ��x-���Ż��Ĳ�����V_L-ʵ���ѹ���ݣ�I_L-ʵ���������
I_ph = x(1); % photo-generated current source ������Դ
I_SD = x(2); % saturation current �����ܵı��͵���
R_s	 = x(3); % series resistance ��������
R_sh = x(4); % shunt resistance ��������
n	 = x(5); % diode ideal factor ��������������
q = 1.60217646e-19; % electron charge ���ӵ�� ��������
k = 1.3806503e-23; % Boltzmann��s constant ��������������������
T = 273.15 + 33.0;		%  �¶ȣ� 33 �� ����¶ȣ���λ�ǿ�����
V_t = k * T / q; %  junction thermal voltage
% �������
Io = I_ph - I_SD * ( exp( (V_L + I_L*R_s) / (V_t*n) ) - 1 ) - ( (V_L + I_L*R_s)/R_sh );
end


%%  -----------------------  PV model with double-diode ---------------------------
function [obj,Io] = PV_2DM(x)
% 2DM��Ŀ�꺯��
a = load('cell_data.txt');% ����ʵ��� ���� ��ѹ����
actual_V_data =  a(:,1);% ʵ���ѹ����
actual_I_data =  a(:,2);% ʵ���������
data_len = length(actual_V_data);
for j=1:data_len
    Io(j) = calculate_objective_2DM(x,actual_V_data(j), actual_I_data(j));
end
error_value = Io-actual_I_data'; % ������� �� ʵ����������
fitness = sum(error_value.^2);
obj = sqrt(fitness/data_len); % Ŀ�꺯�� RMSE
end

function  Io = calculate_objective_2DM(x,V_L,I_L)
% ����2DM�����
% ����Ϊ��x-���Ż��Ĳ�����V_L-ʵ���ѹ���ݣ�I_L-ʵ���������
I_ph	= x(1);% photo-generated current source ������Դ
R_s		= x(2);% series resistance ��������
R_sh	= x(3);% shunt resistance ��������
I_SD1  = x(4); % saturation current ������1�ı��͵���
n1		= x(5);% diode ideal factor ������1����������
I_SD2	= x(6);% saturation current ������2�ı��͵���
n2		= x(7);% diode ideal factor ������2����������

q = 1.60217646e-19;% electron charge ���ӵ�� ��������
k = 1.3806503e-23;% Boltzmann��s constant ��������������������
T = 273.15 + 33.0;		%  the temperature is set as 33 centi-degree ����¶ȣ���λ�ǿ�����

% �������
Io = I_ph - I_SD1 * ( exp( (q*(V_L + I_L*R_s)) / (n1*k*T) ) -1.0 ) - I_SD2 * ( exp( (q*(V_L + I_L*R_s)) / (n2*k*T) ) -1.0 ) - ( (V_L + I_L*R_s)/R_sh );

end


%%  -----------------------  PV model with three-diode ---------------------------
function [obj,Io] = PV_3DM(x)
% 3DM��Ŀ�꺯��
actual_data = load('cell_data.txt');% ����ʵ��� ���� ��ѹ����
actual_V_data =  actual_data(:,1);% ʵ���ѹ����
actual_I_data =  actual_data(:,2);% ʵ���������
data_len = length(actual_V_data);
for j=1:data_len
    Io(j) = calculate_objective_3DM(x,actual_V_data(j), actual_I_data(j));
end
error_value = Io-actual_I_data'; % ������� �� ʵ����������
fitness = sum(error_value.^2);
obj = sqrt(fitness/data_len); % Ŀ�꺯�� RMSE
end

function  Io = calculate_objective_3DM(x,V_L,I_L)
% ����3DM�����
% ����Ϊ��x-���Ż��Ĳ�����V_L-ʵ���ѹ���ݣ�I_L-ʵ���������
I_ph	= x(1);% photo-generated current source ������Դ
R_s		= x(2);% series resistance ��������
R_sh	= x(3);% shunt resistance ��������
I_SD1  = x(4); % saturation current ������1�ı��͵���
n1		= x(5);% diode ideal factor ������1����������
I_SD2	= x(6);% saturation current ������2�ı��͵���
n2		= x(7);% diode ideal factor ������2����������
I_SD3	= x(8);% saturation current ������3�ı��͵���
n3		= x(9);% diode ideal factor ������3����������

q = 1.60217646e-19;% electron charge ���ӵ�� ��������
k = 1.3806503e-23;% Boltzmann��s constant ��������������������
T = 273.15 + 33.0;		%   �¶ȣ� 33 �� ����¶ȣ���λ�ǿ�����

% �������
Io = I_ph - I_SD1 * ( exp( (q*(V_L + I_L*R_s)) / (n1*k*T) ) -1.0 ) - ...
    I_SD2 * ( exp( (q*(V_L + I_L*R_s)) / (n2*k*T) ) -1.0 ) -...
    I_SD3* ( exp( (q*(V_L + I_L*R_s)) / (n3*k*T) ) -1.0 )-( (V_L + I_L*R_s)/R_sh );

end

%%  -----------------------  PV model with four-diode ---------------------------
function [obj,Io] = PV_4DM(x)
% 4DM��Ŀ�꺯��
actual_data = load('cell_data.txt');% ����ʵ��� ���� ��ѹ����
actual_V_data =  actual_data(:,1);% ʵ���ѹ����
actual_I_data =  actual_data(:,2);% ʵ���������
data_len = length(actual_V_data);
for j=1:data_len
    Io(j) = calculate_objective_4DM(x,actual_V_data(j), actual_I_data(j));
end
error_value = Io-actual_I_data'; % ������� �� ʵ����������
fitness = sum(error_value.^2);
obj = sqrt(fitness/data_len); % Ŀ�꺯�� RMSE
end

function  Io = calculate_objective_4DM(x,V_L,I_L)
% ����4DM�����
% ����Ϊ��x-���Ż��Ĳ�����V_L-ʵ���ѹ���ݣ�I_L-ʵ���������
I_ph	= x(1);% photo-generated current source ������Դ
R_s		= x(2);% series resistance ��������
R_sh	= x(3);% shunt resistance ��������
I_SD1  = x(4); % saturation current ������1�ı��͵���
n1		= x(5);% diode ideal factor ������1����������
I_SD2	= x(6);% saturation current ������2�ı��͵���
n2		= x(7);% diode ideal factor ������2����������
I_SD3	= x(8);% saturation current ������3�ı��͵���
n3		= x(9);% diode ideal factor ������3����������
I_SD4	= x(10);% saturation current ������4�ı��͵���
n4		= x(11);% diode ideal factor ������4����������

q = 1.60217646e-19;% electron charge ���ӵ�� ��������
k = 1.3806503e-23;% Boltzmann��s constant ��������������������
T = 273.15 + 33.0;		%   �¶ȣ� 33 �� ����¶ȣ���λ�ǿ�����

% �������
Io = I_ph - I_SD1 * ( exp( (q*(V_L + I_L*R_s)) / (n1*k*T) ) -1.0 ) - ...
    I_SD2 * ( exp( (q*(V_L + I_L*R_s)) / (n2*k*T) ) -1.0 ) -...
    I_SD3* ( exp( (q*(V_L + I_L*R_s)) / (n3*k*T) ) -1.0 )-...
    I_SD4* ( exp( (q*(V_L + I_L*R_s)) / (n4*k*T) ) -1.0 ) - ( (V_L + I_L*R_s)/R_sh );

end

%%  -------------------------  PV module ----------------------------------
function [obj,Io] = PV_module(x,NS,NP)
% ����module�����
actual_data = load('pvmodule_data.txt');% ����ʵ��� ���� ��ѹ����
actual_V_data =  actual_data(:,1);% ʵ���ѹ����
actual_I_data =  actual_data(:,2);% ʵ���������
data_len = length(actual_V_data);
for j=1:data_len
    Io(j) = calculate_objective_module(x,actual_V_data(j), actual_I_data(j),NS,NP);% �����������
end
error_value = Io-actual_I_data'; % ������� �� ʵ����������
fitness = sum(error_value.^2);
obj = sqrt(fitness/data_len); % Ŀ�꺯�� RMSE

end

function  Io = calculate_objective_module(x,V_L,I_L,NS,NP)%%%
% ����module�����
% ����Ϊ��x-���Ż��Ĳ�����V_L-ʵ���ѹ���ݣ�I_L-ʵ���������,NS-�����Ĺܣ�NP-����֧·��
I_ph = x(1);% photo-generated current source ������Դ
I_SD = x(2);% saturation current �����ܵı��͵���
R_s	 = x(3);% series resistance ��������
R_sh = x(4);% shunt resistance ��������
n	 = x(5);% diode ideal factor ��������������
q = 1.60217646e-19;% electron charge ���ӵ�� ��������
k = 1.3806503e-23;% Boltzmann��s constant ��������������������
T = 273.15 + 45.0;		%  %  �¶ȣ� 45�� ����¶ȣ���λ�ǿ�����
V_t = k * T / q;%  junction thermal voltage
% �������
Io = NP*I_ph - NP*I_SD * ( exp( (V_L/NS + (I_L*R_s/NP)) / (V_t*n) ) - 1.0 ) - ( NP*(V_L/NS + (I_L*R_s/NP))/R_sh );

end




