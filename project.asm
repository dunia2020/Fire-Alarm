#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=0800sh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#

; add your code here
        jmp     st1 
        db      1024 dup(0) 
;main program
          
st1:      
        ;clear interrupt flags
        cli 
; intialize ds, es,ss to start of RAM
        mov     ax,0000h
        mov     ds,ax
        mov     es,ax
        mov     ss,ax
        mov     sp,0800H 
        
;intialise porta & b as input &portc as output
        mov     al,92h ;10010010b
        out     06h,al  
                        
;initialise counter mode 2 in 8253                   
        ;30h = address of count0 i.e. starting address for 8253
        ;count reqd = 5*10^6
        ;count0 stores 2500
        mov     al,34h
        out     36h,al 
        mov     al,0C4h
        out     30h,al
        mov     al,09h
        out     30h,al
                           
        ;count1 stores 2000
        mov     al,74h
        out     36h,al
        mov     al,0D0h
        out     32h,al
        mov     al,07h
        out     32h,al
        
        ;take input from smoke sensors
next:   in      al,00h
        mov     bl,al                 
        ;check if both are on or not
        cmp     bl,81h
        jnz     off                 
        
        ;open valves, doors and windows and sound alarm
glow:	mov     al,0C0h
        out     04h,al
        jmp     over
	                                                      
	    ;close valves, doors and windows
off:	mov	    al,0FFh
	    out	    04h,al
        jmp     over            
over:
            
        ;interupt generation using out of 8253 after every 2 seconds
        lea     si,read    
        mov     ds:[256],si  ;vector number = 40h = 64d, so location in IVT = 64*4 = 256
        mov     cx,cs
        mov     ds:[258],cx
        
        ;set the interrupt flags
        sti
        
        ;infinite loop, will stop only power s switched off
        jmp     next
        
read proc near:   
        iret
read endp    