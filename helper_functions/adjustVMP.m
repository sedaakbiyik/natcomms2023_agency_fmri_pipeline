function adjustVMP(fn,min,max)

vmp = xff(fn);

vmp.Map.LowerThreshold=min;
vmp.Map.UpperThreshold=max;

[a b c]=fileparts(fn);
vmp.Map.Name = b;
vmp.Map.LUTName = './Accuracy_colors.olt';

vmp.SaveAs(fn);