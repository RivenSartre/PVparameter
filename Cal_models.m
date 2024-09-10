function [Vm,Im,Pm,Io,Po,IIAE,IRE,PIAE,PRE]=Cal_models(x,pv_type)
% ��ע΢�Ź��ںţ��Ż��㷨��   Swarm-Opti
% https://mbd.pub/o/author-a2mVmGpsYw==
% �����
% Io-���Ƶ���ֵ
% Po-���ƹ���ֵ
% Vm-ʵ���ѹ����
% Im-ʵ���������
% Pm-��Vm��Im�����ʵ�⹦��
% IIAE-������absolute error
% IRE-������relative error
% PIAE-���ʵ�absolute error
% PRE-���ʵ�absolute error
%%

switch pv_type
    case '1DM'
        %  PV model with single-diode
        actual_data = load('cell_data.txt');% ����ʵ��� ���� ��ѹ����
        Vm =  actual_data(:,1);% ʵ���ѹ����
        Im =  actual_data(:,2);% ʵ���������
        x_str={'I_ph','I_SD','R_s','R_sh','n'};
        [~,~,~,fun,~] = select_PV_model(pv_type);
        [fobj,Io]=fun(x);
        Io=Io';
        IIAE=abs(Io-Im); % ������absolute error
        IRE=(Im-Io)./Im; % ������relative error
        Pm=Vm.*Im;%��Vm��Im�����ʵ�⹦��
        Po=Vm.*Io; %���ƹ���ֵ
        PIAE=abs(Pm-Po);% ���ʵ�absolute error
        PRE=(Pm-Po)./Pm;% ���ʵ�absolute error
        
    case '2DM'
        %  PV model with double-diode
        actual_data = load('cell_data.txt');% ����ʵ��� ���� ��ѹ����
        Vm =  actual_data(:,1);% ʵ���ѹ����
        Im =  actual_data(:,2);% ʵ���������
        x_str={'I_ph','R_s','R_sh','I_SD1','n1','I_SD2','n2'};
        [~,~,~,fun,~] = select_PV_model(pv_type);
        [fobj,Io]=fun(x);
        Io=Io';
        IIAE=abs(Io-Im); % ������absolute error
        IRE=(Im-Io)./Im; % ������relative error
        Pm=Vm.*Im;%��Vm��Im�����ʵ�⹦��
        Po=Vm.*Io; %���ƹ���ֵ
        PIAE=abs(Pm-Po);% ���ʵ�absolute error
        PRE=(Pm-Po)./Pm;% ���ʵ�absolute error
        
    case '3DM'
        % PV model with three-diode
        actual_data = load('cell_data.txt');% ����ʵ��� ���� ��ѹ����
        Vm =  actual_data(:,1);% ʵ���ѹ����
        Im =  actual_data(:,2);% ʵ���������
        x_str={'I_ph','R_s','R_sh','I_SD1','n1','I_SD2','n2','I_SD3','n3'};
        [~,~,~,fun,~] = select_PV_model(pv_type);
        [fobj,Io]=fun(x);
        Io=Io';
        IIAE=abs(Io-Im); % ������absolute error
        IRE=(Im-Io)./Im; % ������relative error
        Pm=Vm.*Im;%��Vm��Im�����ʵ�⹦��
        Po=Vm.*Io; %���ƹ���ֵ
        PIAE=abs(Pm-Po);% ���ʵ�absolute error
        PRE=(Pm-Po)./Pm;% ���ʵ�absolute error
        
    case '4DM'
        % PV model with three-diode
        actual_data = load('cell_data.txt');% ����ʵ��� ���� ��ѹ����
        Vm =  actual_data(:,1);% ʵ���ѹ����
        Im =  actual_data(:,2);% ʵ���������
        x_str={'I_ph','R_s','R_sh','I_SD1','n1','I_SD2','n2','I_SD3','n3','I_SD4','n4'};
        [~,~,~,fun,~] = select_PV_model(pv_type);
        [fobj,Io]=fun(x);
        Io=Io';
        IIAE=abs(Io-Im); % ������absolute error
        IRE=(Im-Io)./Im; % ������relative error
        Pm=Vm.*Im;%��Vm��Im�����ʵ�⹦��
        Po=Vm.*Io; %���ƹ���ֵ
        PIAE=abs(Pm-Po);% ���ʵ�absolute error
        PRE=(Pm-Po)./Pm;% ���ʵ�absolute error
        
    case 'PMM'
        %  PV model with module-diode
        actual_data = load('pvmodule_data.txt');% ����ʵ��� ���� ��ѹ����
        Vm =  actual_data(:,1);% ʵ���ѹ����
        Im =  actual_data(:,2);% ʵ���������
        x_str={'I_ph','I_SD','R_s','R_sh','n'};
        [~,~,~,fun,~] = select_PV_model(pv_type);
        [fobj,Io]=fun(x);
        Io=Io';
        IIAE=abs(Io-Im); % ������absolute error
        IRE=(Im-Io)./Im; % ������relative error
        Pm=Vm.*Im;%��Vm��Im�����ʵ�⹦��
        Po=Vm.*Io; %���ƹ���ֵ
        PIAE=abs(Pm-Po);% ���ʵ�absolute error
        PRE=(Pm-Po)./Pm;% ���ʵ�absolute error
        
end



end





