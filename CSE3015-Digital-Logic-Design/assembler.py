def read_instruction():
    with open('instruction.txt') as instraction_set:
     instruction = [instruction.rstrip('\n') for instruction in instraction_set]
    return instruction

def bindigits(n, bits):
    s = bin(n & int("1"*bits, 2))[2:]
    return ("{0:0>%s}" % (bits)).format(s)

def get_binary_code(ins):
 ins_code = ins.split(' ')[0]
 machine_text = ''

 match ins_code:

  case 'ADD' | 'SUB' | 'AND' | 'OR' | 'XOR':
    ins_starting_index = ins.index(',')
    start_index = 4

    if ins_code == 'ADD':
     machine_text += '00000'
    elif ins_code == 'SUB':
     machine_text += '00010'
    elif ins_code == 'AND':
     machine_text += '00100'
    elif ins_code == 'OR':
     start_index=3
     machine_text += '00110' 
    elif ins_code == 'XOR':
     machine_text += '01000'  

    binary_form=str(bin(int((ins[start_index:ins_starting_index])[1:]))[2:].zfill(4))
    machine_text += binary_form
    new_sub_string = ins[ins_starting_index+1:]
    f1 = new_sub_string.index(',')
    source_code0 = new_sub_string[:f1]
    binary_form_source_0=str(bin(int(source_code0[1:]))[2:].zfill(4))
    machine_text += binary_form_source_0
    new_sub_string1 = new_sub_string[f1+1:]
    binary_form_source_1=str(bin(int(new_sub_string1[1:]))[2:].zfill(4))
    machine_text += binary_form_source_1
    return machine_text + '000'

  case 'ADDI' | 'SUBI' | 'ANDI' |'ORI' | 'XORI' | 'BE' | 'BNE':
    ins_starting_index = ins.index(',')
    start_index = 5

    if ins_code == 'ADDI':
     machine_text += '00001'
    elif ins_code == 'SUBI':
     machine_text += '00011'
    elif ins_code == 'ANDI':
     machine_text += '00101'
    elif ins_code == 'ORI':
     start_index = 4 
     machine_text += '00111'
    elif ins_code == 'XORI':
     machine_text += '01001'
    elif ins_code == 'BE':
     start_index = 3 
     machine_text += '10100'
    elif ins_code == 'BNE':
     start_index = 4
     machine_text += '10110'
    
  
    binary_form=str(bin(int(ins[start_index:ins_starting_index][1:]))[2:].zfill(4))
    machine_text += binary_form
    new_sub_string = ins[ins_starting_index+1:]
    f1 = new_sub_string.index(',')
    source_code = new_sub_string[:f1]
    binary_form_source=str(bin(int(source_code[1:]))[2:].zfill(4))
    machine_text += binary_form_source
    binary_imm_extend =bindigits(int(new_sub_string[f1+1:][0:]),7)
    machine_text += binary_imm_extend
    return  machine_text
  
 
  case 'JMP':
     ins_starting_index = ins.index(' ')
     machine_text += '0111'
     adress_binary = bindigits(int(ins[ins_starting_index+1:]),10) 
     machine_text += adress_binary
     return machine_text + '000000'
     
  case 'PUSH' | 'POP':
     ins_starting_index = ins.index(' ')

     if ins_code == 'PUSH':
      machine_text += '10001'
     elif ins_code == 'POP':
      machine_text += '10011'

     adress_binary = str(bin(int(ins[ins_starting_index+2:]))[2:].zfill(4))
     machine_text += adress_binary
     return machine_text + '00000000000'
   
  case 'LD' | 'ST':
    ins_starting_index = ins.index(' ')
    if ins_code == 'LD':
      machine_text += '01010'
    elif ins_code == 'ST':
      machine_text += '01100'
    
    new_sub_string = ins[ins_starting_index+1:]
    f1 = new_sub_string.index(',')
    dest = new_sub_string[1:f1]
    binary_form=str(bin(int(dest))[2:].zfill(4))
    machine_text += binary_form
    imm_binary = bindigits(int(new_sub_string[f1+1:]),10)
    machine_text += '0'
    machine_text += imm_binary
    return machine_text

def main():

    f = open("output.txt", "a")
    f.write('v2.0 raw\n')
    instructions = read_instruction()
    for ins in instructions:
     machine_code = get_binary_code(ins)
     hex_value = hex(int(machine_code,2))[2:]
     if len(hex_value) != 5:
      hex_value = '0' + hex_value
     print(hex_value)
     f.write(hex_value)
     f.write(' ')


if __name__ == '__main__':
    main()