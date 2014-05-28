clear all
close all

input_spectra=importdata('input_spectra.txt');
LED_Spectra=importdata('LED_Spectra.txt');

Wavelength=350:.5:850

input_spectra=spline(input_spectra(:,1),input_spectra(:,2),Wavelength);
input_spectra(input_spectra<0)=0;


x=[Wavelength' input_spectra']
plot(Wavelength,input_spectra)