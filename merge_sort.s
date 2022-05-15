	AREA rw, DATA,READWRITE

arr dcd 132,11,13,7,34,6,5,23,38,54,2,19,22,65
templeft dcd 132,11,13,7,34,6,5,23,38,54,2,19,22,65
tempright dcd 132,11,13,7,34,6,5,23,38,54,2,19,22,65
	
	AREA r, CODE, READONLY
	ENTRY

n equ 13 ; n= dimension - 1 = 9-1
	
	ldr r1,=arr ; ** pointer to array
	mov r4,#0 ; counter for fill array
	ldr r8,=n ; dimension

fillarray ; fills the array arr using fillarr becaue arrays defined in readwrite area are empty
	cmp r8,r4
	blt mergesort
	ldr r2,=fillarr
	ldr r3,[r2,r4,lsl #2]
	str r3,[r1,r4,lsl #2]
	add r4,#1
	b fillarray
	

mergesort
	mov r8,#0 ;clean r8
	mov r4,#0 ; clean counter
	mov r2,#1 ; ** current size - current size of sub arrays to be merged
	mov r3,#0 ; ** left start - for picking starting index of left subarray
	
; ** r0, ** r4 , ** r5 temp registers

loop1

	ldr r0,=n 
	cmp r0,r2 ; current size compare to n-1
	ble endline ; if less equal go to finish
	mov r3,#0 ; ** left start
	b loop2 
loop1return 
	mov r4,#2 ; to increase current size by current size *2 use multiplication
	mul r5,r2,r4
	mov r2,#0
	add r2,r5 
	b loop1
	
loop2
	
	ldr r0,=n
	cmp r0,r3
	ble loop1return
	
	mov r6,#0 ; ** mid - mid +1 is starting point of right sub array
	mov r7,#0 ; ** right end
	
	bl findmid  ; find mid = min(left_start + curr_size - 1, n-1)
	bl findright ; find right = min(left_start + 2*curr_size - 1, n-1)
	bl merge ; call the function to merge sub arrays
	

merge
	mov r0,#0
	sub r0,r6,r3 ; n1 = m-l+1
	add r0,r0,#1
	mov r8,r0 ; ** r8 = n1
	
	mov r0,#0
	sub r0,r7,r6 ; n2=r-m
	mov r9,r0 ; ** r9 = n2
	
	mov r0,#0
	ldr r4,=templeft  ;
	ldr r5,=tempright ;
	bl copyloop1 ; copy data to temp array left
	mov r0,#0 ; ** ro=i
	mov r12,#0 ; ** r12=j
	mov r11,r3 ; ** r11=k
	
	bl whileloop1 ; merge the temp arrays into array
	bl whileloop2
	bl whileloop3
	mov r4,#2
	mul r5,r2,r4
	add r3,r5
	b loop2
	
	
whileloop3  ; copy remaining elements of right temp array
	cmp r12,r9 
	ble returntomerge
	ldr r5,=tempright
	ldr r10,[r5,r12,lsl #2] ; x = R[i]
	str r10,[r1,r11,lsl #2] ; arr[k] = x
	add r12,#1
	add r11,#1
	b whileloop3
	
whileloop2 ; copy remaining elements of left temp array
	cmp r8,r0
	ble returntomerge
	ldr r4,=templeft
	ldr r10,[r4,r0,lsl #2] ;  x = L[i]
	str r10,[r1,r11,lsl #2] ; arr[k] = x
	add r0,#1 ; i++
	add r11,#1 ; j++
	b whileloop2
	
whileloop1
	ldr r4,=templeft  ;
	ldr r5,=tempright ;
	cmp r0,r8 
	bge returntomerge ; calling this will return to main merge function with link register
	cmp r12,r9
	bge returntomerge
	
	ldr r10,[r5,r12,lsl #2] ; r10=R[J]  
	ldr r5,[r4,r0,lsl #2] ; r5=L[I]
	cmp r5,r10 ; if L[i] <= R[j]
	ble firstif
outoffirstif
    b secondif

firstif
	ldr r10,[r4,r0,lsl #2] ; L[i]
	str r10,[r1,r11,lsl #2] ; arr[k] = L[i]
	add r0,#1 ; i++
	add r11,#1 ; k++
	b whileloop1
	
secondif
	ldr r5,=tempright
	ldr r10,[r5,r12,lsl #2] ; R[j]
	str r10,[r1,r11,lsl #2] ; arr[k] = L[i]
	add r12,#1
	add r11,#1
	b whileloop1

copyloop1
	cmp r0,r8 ; compare the index with n2
	bge copyloop2start ; once done, jump to other copy loop to copy remainin data to right temp array
	mov r11,#0
	add r11,r3,r0
	ldr r10,[r1,r11,lsl #2]
	str r10,[r4,r0,lsl #2] ; copy to left temp array
	add r0,#1
	b copyloop1

copyloop2start
	mov r0,#0
	b copyloop2
	
copyloop2
	cmp r0,r9
	bge returntomerge
	mov r11,#0
	add r11,r6,#1
	add r11,r11,r0
	ldr r10,[r1,r11,lsl #2]
	str r10,[r5,r0,lsl #2]
	add r0,#1
	b copyloop2
	
returntomerge
	bx lr
	
findmid ; calculate mid value mid=min(left_start + curr_size - 1, n-1)
	ldr r0,=n ; r0 = n-1 
	mov r4,#0
	add r4,r3,r2
	sub r4,r4,#1
	cmp r4,r0 ; r4 = leftstart+currentsize-1
	bge midr0 
	mov r6,r4
	bx lr
	
midr0
	mov r6,r0
	bx lr
	
findright ; calculate rightend value =min(left_start + 2*curr_size - 1, n-1)
	ldr r0,=n 
	mov r4,#2
	mul r5,r2,r4
	mov r4,#0
	add r4,r3,r5
	sub r4,r4,#1
	cmp r4,r0
	bge rightr0
	mov r7,r4
	bx lr

rightr0
	mov r7,r0
	bx lr

return 
	pop {lr}
	bx lr

fillarr dcd 132,11,13,7,34,6,5,23,38,54,2,19,22,65
	
endline
	END