function initialpressure=creatinitialpressure(Model, Medium, Geometry,absorption_coefficient)
%this function creats an initial pressure distribution inside the cuvette.
%it assumes that the laser beam is collimated.
H_1=round((Geometry.cuvette_face)/Model.dx);
p_0=zeros(Model.Nx,Model.Ny);
for i=1:round(Geometry.cuvette_length/Model.dx)+1
   for j=1:round(Geometry.cuvette_diameter/(2*Model.dy))
       x=Model.dx*i;
       y=Model.dy*j;
       %p_0(floor((0.011/Model.dx))+i,j)=Model.amplitude*Medium.absorption*Model.dx*exp(-Medium.absorption*x);%Gaussian
       p_0(H_1+i,j)=exp(-((y^2)/(Geometry.q^2))^Geometry.p)*Model.amplitude*absorption_coefficient*Model.dx*exp(-absorption_coefficient*x);%Tophat
    end
end
initialpressure=p_0;
end