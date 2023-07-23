function RMSEcalculated= calculateRMSE(Model, Medium, Geometry,absorption_coefficient,a)
global S_model_processed
global S_exp_processed
global S_model
global S_exp
S_model=forward_homogeneous(Model, Medium, Geometry,absorption_coefficient);
[S_model_processed, S_exp_processed] =processsignals(S_model,S_exp, Model, Medium,Geometry,a);
RMSEcalculated=sqrt(mean((S_exp_processed-S_model_processed).^2))/sqrt(mean((S_exp_processed).^2))*100;

%[absorption_coefficient,a, RMSEcalculated]
%RMSEcalculated=abs(min(S_exp_processed(:))-min(S_model_processed(:)))/abs(min(S_exp_processed(:)));
end