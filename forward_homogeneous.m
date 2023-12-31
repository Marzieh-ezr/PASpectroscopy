
function PAsignal=forward_homogeneous(Model, Medium, Geometry,absorption_coefficient)
%inputs:
%speed of sound:

% create the computational grid

global source;
global sensor_data;
global sensor;
global medium; 


kgrid = kWaveGrid(Model.Nx, Model.dx, Model.Ny, Model.dy);
kgrid.t_array=0:1/Model.sample_rate_model:50e-6;



%find the boundries of the cuvette
length=Geometry.cuvette_length-2*Geometry.cuvette_Gasket;
H_1=round((Geometry.cuvette_face)/Model.dx);
H_2=H_1+round(Geometry.cuvette_Gasket/Model.dx);
H_3=H_2+round(length/Model.dx);
H_4=H_3+round(Geometry.cuvette_Gasket/Model.dx);
H_5=H_4+round(Geometry.cuvette_face/Model.dx);

% define the properties of the propagation medium
medium.sound_speed = Medium.speed_of_sound*ones(Model.Nx, Model.Ny);  % [m/s]
medium.sound_speed_ref=Medium.speed_of_sound;
medium.sound_speed(H_1+1:H_1+round(Geometry.cuvette_length/Model.dx), 1:round(Geometry.cuvette_diameter/2/Model.dy)+1)= Medium.sound_speed_sample;

medium.density=997*ones(Model.Nx, Model.Ny);
medium.density(H_1+1:H_1+round(Geometry.cuvette_length/Model.dx), 1:round(Geometry.cuvette_diameter/2/Model.dy)+1)= Medium.density_sample;



% create initial pressure distribution.
%source.p0 = creatinitialpressure(Model, Medium, Geometry);%collimated Beam
source.p0 =creatinitialpressure_DB(Model, Medium, Geometry,absorption_coefficient);%divergent Beam

% define a sensor mask
sensor.mask=zeros(Model.Nx,Model.Ny);
%binary
sensor.mask(H_4+round((Geometry.distance/Model.dx)):...
H_4+round(((Geometry.distance+Geometry.sensor_thikness)/Model.dx))-1,1:round(Geometry.l/2/Model.dy))=1;
%opposing corner
%sensor.mask = [H_4+round((Geometry.distance/Model.dx)), 1,...
    %H_4+round(((Geometry.distance+Geometry.sensor_thikness)/Model.dx))-1,...
    %round(Geometry.l/2/Model.dy)].'; 

input_args = { 'DataCast', 'gpuArray-single','PMLSize', 100};
% run the simulation
sensor_data = kspaceFirstOrderAS(kgrid, medium, source, sensor, input_args{:}, 'PlotSim', false,...
    'PlotLayout', false,'Smooth',[true,false,false]);
sensor_data=gather(sensor_data);

%integrate signals from all the sensor elements
Sdata=size(sensor_data);%binary sensor mask
%Sdata=size(sensor_data.p(:,:,:));%opposing corner sensor mask
%sensor_data_integrated=gpuArray(zeros(1,Sdata(1,3)));%opposing corner
sensor_data_integrated=gpuArray(zeros(1,Sdata(1,2)));%binary sensor mask

a=Sdata(1,1)/round(Geometry.sensor_thikness/Model.dx);%binary sensor mask

S_mat=mat2cell(sensor_data,(Sdata(1,1)/a*ones(1,a)));%binary sensor mask
%if Sdata(1,1)==1
    %S_y=squeeze(sensor_data.p(:,:,:))*Model.dx;%opposing corner sensor mask
%else
    %S_y=squeeze(trapz(sensor_data.p(:,:,:)))*Model.dx;%opposing corner sensor mask
%end
%n=1:a %opposing corner sensor mask
%Y=(n-1/2)*Model.dy;%opposing corner sensor mask
%S_y=S_y.*Y';%opposing corner sensor mask
%sensor_data_integrated(1,:)=trapz(S_y)*2*pi()*Model.dy;%opoosing corner
S_matt=cell(21,1)
for n=1:a
    Y=(n)*Model.dy;
    S_Y=cell2mat(S_mat(n,1))*Y;
    S_matt{n,1}=double(S_Y);
    %sensor_data_integrated(1,:) =trapz(cell2mat(S_mat(n,1)))*2*pi()*Y+sensor_data_integrated(1,:);%binary sensor mask
    %sensor_data_integrated(1,:) =S_y(n,:)*2*pi()*Y+sensor_data_integrated(1,:)*Model.dy;%opposing corner sensor mask
end
sensor_data_integrated=trapz(cell2mat(S_matt(:)))*2*pi()*Model.dy*Model.dx
PAsignal=gather(sensor_data_integrated);

end