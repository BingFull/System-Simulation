function food_req_num = food_require( )
%UNTITLED �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    ra = randi(600);
    if(ra <= 100)
        food_req_num = 1;     
    elseif(ra > 100 && ra <= 300)
        food_req_num = 2;
    elseif(ra > 300 && ra <= 500)
        food_req_num = 3;
    else
        food_req_num = 4; 
    end
end