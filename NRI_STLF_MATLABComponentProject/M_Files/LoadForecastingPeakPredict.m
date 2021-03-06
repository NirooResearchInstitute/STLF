function [corp]=LoadForecastingPeakPredict(yy,mm,dd,days,corp,InputData,METHOD)

% find selected day
i=find((InputData.cal.calH(:,1)==yy)&(InputData.cal.calH(:,2)==mm)&(InputData.cal.calH(:,3)==dd));
knew=find((InputData.Zone{1,1}.Load.Interchange(:,1)==yy)&(InputData.Zone{1,1}.Load.Interchange(:,2)==mm)&(InputData.Zone{1,1}.Load.Interchange(:,3)==dd));

zoneNo=length(corp.zone);



for k=1:15   
    SLoad=[];
    if ~strcmp(corp.name,'system')    
        for z=1:zoneNo
            SLoad = [SLoad;InputData.Zone{1,z}.Load.Manategh(i-k,6:29)+InputData.Zone{1,z}.Load.Industrial(knew-k,6:29)+...
                InputData.Zone{1,z}.Load.Pump(knew-k,6:29)+InputData.Zone{1,z}.Load.Interchange(knew-k,6:29)];
        end
        SumLoad= sum(SLoad);
    else
        SumLoad = InputData.Zone{1,1}.Load.Manategh(i-k,6:29);
    end
    dPH1(k) = find(SumLoad==max(SumLoad(12:17)));
    nPH1(k) = find(SumLoad==max(SumLoad(18:23)));
end

for k=1:days
    predictLoad=eval(['corp.',METHOD,'.Predict.Total(k,1:24)']);
    dPH(k) = find(predictLoad==max(predictLoad(12:17)));
    nPH(k) = find(predictLoad==max(predictLoad(18:23)));
end

for z = 1:zoneNo
    mm2=mm;
    dd2=dd;
    yy2 =yy;
    
    AA = InputData.Zone{1,z}.Load.Manategh;
    AA(:,1:5) = InputData.cal.calH;
    
    for k=1:days
        

        [nightPeakPredict,dayPeakPredict]=peakpredictZ(AA(1:k+i-1,1:29),AA(1:k+i-1,30:31),eval(['corp.zone{1,z}.',METHOD,'.Predict.Manategh(k,1:24)']),dPH(k),nPH(k),dPH1,nPH1);
        eval(sprintf('%s=%s',['corp.zone{1,z}.',METHOD,'.Predict.Manategh(k,25:26)'],'[nightPeakPredict dayPeakPredict];'));
        AA(k+i-1,6:31)=eval(['corp.zone{1,z}.',METHOD,'.Predict.Manategh(k,1:26)']);
        
%         if ~strcmp(corp.name,'system')
            knew=find((InputData.Zone{1,z}.Load.Interchange(:,1)==yy2)&(InputData.Zone{1,z}.Load.Interchange(:,2)==mm2)&(InputData.Zone{1,z}.Load.Interchange(:,3)==dd2));
            
            INDUSTRIAL=InputData.Zone{1,z}.Load.Industrial;
            PUMP=InputData.Zone{1,z}.Load.Pump;
            INTERCHANGE=InputData.Zone{1,z}.Load.Interchange;
            
            [nightPeakPredict,dayPeakPredict]=peakpredictZ(INDUSTRIAL(1:knew,1:29),INDUSTRIAL(1:knew,30:31),eval(['corp.zone{1,z}.',METHOD,'.Predict.Industrial(k,1:24)']),dPH(k),nPH(k),dPH1,nPH1);
            eval(sprintf('%s=%s',['corp.zone{1,z}.',METHOD,'.Predict.Industrial(k,25:26)'],'[nightPeakPredict dayPeakPredict];'));
            INDUSTRIAL(knew,6:31)=eval(['corp.zone{1,z}.',METHOD,'.Predict.Industrial(k,1:26)']);
            
            [nightPeakPredict,dayPeakPredict]=peakpredictZ(PUMP(1:knew,1:29),PUMP(1:knew,30:31),eval(['corp.zone{1,z}.',METHOD,'.Predict.Pump(k,1:24)']),dPH(k),nPH(k),dPH1,nPH1);
            eval(sprintf('%s=%s',['corp.zone{1,z}.',METHOD,'.Predict.Pump(k,25:26)'],'[nightPeakPredict dayPeakPredict];'));
            PUMP(knew,6:31)=eval(['corp.zone{1,z}.',METHOD,'.Predict.Pump(k,1:26)']);
            
            [nightPeakPredict,dayPeakPredict]=peakpredictZ(INTERCHANGE(1:knew,1:29),INTERCHANGE(1:knew,30:31),eval(['corp.zone{1,z}.',METHOD,'.Predict.Interchange(k,1:24)']),dPH(k),nPH(k),dPH1,nPH1);
            eval(sprintf('%s=%s',['corp.zone{1,z}.',METHOD,'.Predict.Interchange(k,25:26)'],'[nightPeakPredict dayPeakPredict];'));
            INTERCHANGE(knew,6:31)=eval(['corp.zone{1,z}.',METHOD,'.Predict.Interchange(k,1:26)']);
%         end
        if (k<size(InputData.Zone{1,z}.Load.Manategh,1))
            dd2=AA(k+i,3);
            mm2=AA(k+i,2);
            yy2=AA(k+i,1);
        end
    end
end
% summation of zones for corp

TotalPeak=0;
TotalManateghPeak=0;
TotalPumpPeak=0;
TotalIndustrialPeak=0;
TotalInterchangePeak=0;
for z=1:zoneNo
    TotalManateghPeakZone=eval(['corp.zone{1,z}.',METHOD,'.Predict.Manategh(:,25:26)']);
    TotalPumpPeakZone=eval(['corp.zone{1,z}.',METHOD,'.Predict.Pump(:,25:26)']);
    TotalInterchangePeakZone=eval(['corp.zone{1,z}.',METHOD,'.Predict.Interchange(:,25:26)']);
    TotalIndustrialPeakZone=eval(['corp.zone{1,z}.',METHOD,'.Predict.Industrial(:,25:26)']);
    TotalPeakZone=TotalManateghPeakZone+TotalPumpPeakZone+TotalInterchangePeakZone+TotalIndustrialPeakZone;
    eval(sprintf('%s=%s',['corp.zone{1,z}.',METHOD,'.Predict.Total(:,25:26)'],'TotalPeakZone;'));

    TotalManateghPeak=TotalManateghPeak+TotalManateghPeakZone;
    TotalPumpPeak=TotalPumpPeak+TotalPumpPeakZone;
    TotalInterchangePeak=TotalInterchangePeak+TotalInterchangePeakZone;
    TotalIndustrialPeak=TotalIndustrialPeak+TotalIndustrialPeakZone;
    
    TotalPeak=TotalPeak+TotalPeakZone;
end

eval(sprintf('%s=%s',['corp.',METHOD,'.Predict.Total(:,25:26)'],'TotalPeak;'));
eval(sprintf('%s=%s',['corp.',METHOD,'.Predict.Pump(:,25:26)'],'TotalPumpPeak;'));
eval(sprintf('%s=%s',['corp.',METHOD,'.Predict.Industrial(:,25:26)'],'TotalIndustrialPeak;'));
eval(sprintf('%s=%s',['corp.',METHOD,'.Predict.Interchange(:,25:26)'],'TotalInterchangePeak;'));
eval(sprintf('%s=%s',['corp.',METHOD,'.Predict.Manategh(:,25:26)'],'TotalManateghPeak;'));