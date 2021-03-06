clc;clear;close all;
tStart=tic;

load('optLibs.mat');
%Open start file, where the scheme will be drawn
directory = fullfile(pwd,'SM_SPM.osd');
optsys = OpenOptisystem(directory);

%Get main system variables
Document = optsys.GetActiveDocument;
LayoutMgr = Document.GetLayoutMgr;
Layout = LayoutMgr.GetCurrentLayout;
Canvas = Layout.GetCurrentCanvas;
PmMgr = Layout.GetParameterMgr;

centFreq = 193.1;% central frequency in THz
modFreq = 12.5;% modulation frequency in GHz
BandwidthForInv = 20; %GHz
BandwidthForRect = 30; %GHz
d2 = 17;% dispersion in ps/nm/km
% Aeff = 80*1.3145/7.6;
Aeff = 80;% effective mode area in mkm^2
L = 2;% length of fiber in km
Att = 0.2;% attenuation in dB/km

Powers = 10:20;% power of beat signal at the beginning of the fiber

Las = Canvas.GetComponentByName('CW Laser');
Gen = Canvas.GetComponentByName('Sine Generator');
InvRect = Canvas.GetComponentByName('Inverted Rectangle Optical Filter');
RectFilt = Canvas.GetComponentByName('Rectangle Optical Filter_2');
Ampl = Canvas.GetComponentByName('Optical Amplifier');
Fiber = Canvas.GetComponentByName('Optical Fiber');
OPM = Canvas.GetComponentByName('Optical Power Meter');

FiltBranch1 = Canvas.GetComponentByName('Rectangle Optical Filter');
FiltBranch2 = Canvas.GetComponentByName('Rectangle Optical Filter_1');
OPM1 = Canvas.GetComponentByName('Optical Power Meter_1');
OPM2 = Canvas.GetComponentByName('Optical Power Meter_2');

Las.SetParameterValue('Frequency',centFreq);
Gen.SetParameterValue('Frequency',modFreq);
InvRect.SetParameterValue('Frequency',centFreq);
InvRect.SetParameterValue('Bandwidth',BandwidthForInv);
RectFilt.SetParameterValue('Frequency',centFreq);
RectFilt.SetParameterValue('Bandwidth',BandwidthForRect);

Fiber.SetParameterValue('Attenuation',Att);
Fiber.SetParameterValue('Length',L);
Fiber.SetParameterValue('Dispersion',d2);
Fiber.SetParameterValue('Dispersion slope',0);
Fiber.SetParameterValue('Effective area',Aeff);

FiltBranch1.SetParameterValue('Frequency',centFreq+modFreq/1000);
FiltBranch2.SetParameterValue('Frequency',centFreq+3*modFreq/1000);

timeForFile=datestr(now,'mm-dd-yyyy_HH_MM_SS');

P1 = zeros(length(Powers),1);
P2 = zeros(length(Powers),1);

Canvas.UpdateAll;%draw all created components and connections
Document.Save(strcat(pwd,'\SM_SPM.osd'));

for q=1:length(Powers)
    disp(Powers(q));
    Ampl.SetParameterValue('Power',Powers(q));
    Document.CalculateProject(true,true);
    P1(q) = OPM1.GetResultValue('Total Power (dBm)');
    P2(q) = OPM2.GetResultValue('Total Power (dBm)');
end

fileName = [timeForFile,sprintf('_SM_SPM_Powers = %d - %d dBm_disp = %d',Powers(1),Powers(end),d2)];
save(fileName);

timeOfCals = toc(tStart);
optsys.Quit;
clear optsys;