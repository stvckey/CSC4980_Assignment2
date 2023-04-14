%% Integral Image
% 
% Description:
%   This program resizes the input image (img) using the integral image (II). To this 
%   end, the integral image is first computed over the image, for then to resize the 
%   image according to the cell size parameter (cs). To keep efficiency, this program 
%   makes use of mex files.
%
% Contact:
%   Michael Villamizar
%   mvillami-at-iri.upc.edu
%   Institut de Robòtica i Informática Industrial CSIC-UPC
%   Barcelona - Spain
%   2014
%

%% Main function
function prg_integral_image()
clc,close all,clear all

% message
fun_messages('Integral Image','presentation');
fun_messages('Integral Image','title');

% parameters
cs = 2;  % cell size (integer)
fs = 10;  % font size
imgPath = './images/TDeck_team06_3.jpeg';  % image file path

% load image
img = imread(imgPath);
%img = rgb2gray(img);  % gray-scale image [comment this line for color images]

% image size
[sy,sx,nc] = size(img);

% message
fun_messages('input image:','process');
fun_messages(sprintf('image size -> [%d x %d]',sy,sx),'information');
fun_messages(sprintf('num.channels -> %d',nc),'information');

% show image
figure,imshow(img),title('Input Image','fontsize',fs),xlabel(sprintf('Size -> [%d x %d]',sy,sx));

% compute the integral image over the input image: img->II
tic; II = mex_img2II(double(img)); t1 = toc;

% compute the resized image from the integral image: II->img
tic; img = mex_II2Img(II,cs); t2 = toc;

% messages
fun_messages('times:','process');
fun_messages(sprintf('img -> II : %.5f [sec.]',t1),'information');
fun_messages(sprintf('II -> img : %.5f [sec.]',t2),'information');

% image size
[sy,sx,nc] = size(img);

% message
fun_messages('output image:','process');
fun_messages(sprintf('image size -> [%d x %d]',sy,sx),'information');
fun_messages(sprintf('num.channels -> %d',nc),'information');

% show image
figure,imshow(uint8(img)),title('Output Image','fontsize',fs),xlabel(sprintf('Size -> [%d x %d]',sy,sx));

%message
fun_messages('end','title');

end

%% messages
% This function prints a specific message on the command window
function fun_messages(text,message)
if (nargin~=2), error('incorrect input parameters'); end

% types of messages
switch (message)
    case 'presentation'
        fprintf('****************************************************\n');
        fprintf(' %s\n',text);
        fprintf('****************************************************\n');
        fprintf(' Michael Villamizar\n mvillami@iri.upc.edu\n');
        fprintf(' http://www.iri.upc.edu/people/mvillami/\n');
        fprintf(' Institut de Robòtica i Informàtica Industrial CSIC-UPC\n');
        fprintf(' c. Llorens i Artigas 4-6\n 08028 - Barcelona - Spain\n 2014\n');
        fprintf('****************************************************\n\n');
    case 'title'
        fprintf('****************************************************\n');
        fprintf('%s\n',text);
        fprintf('****************************************************\n');
    case 'process'
        fprintf('-> %s\n',text);
    case 'information'
        fprintf('->     %s\n',text);
    case 'warning'
        fprintf('-> %s !!!\n',text);
    case 'error'
        fprintf(':$ ERROR : %s\n',text);
        error('program error');
end
end
