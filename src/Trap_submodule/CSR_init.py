import sys
import pandas as pd
file_path = 'E:/Linux_share/QianTang_Processors/user/src/Trap_submodule/'
def replace_field_in_file(oldfile_path, start_marker, end_marker, newfile_path, new_field):
    # 打开文件并读取内容
    with open(oldfile_path, 'r',encoding='utf-8') as file:
        content = file.read()
    # # 使用replace()方法或正则表达式替换字段
    # for i in range(len(old_field)) :
    #     content = content.replace(old_field[i], new_field[i])
    for i in range(len(start_marker)):
        start_index = content.find(start_marker[i])
        end_index = content.find(end_marker[i]) + len(end_marker[i])
        if start_index != -1 and end_index != -1:
            content = content[:start_index] + new_field[i] + content[end_index:]
    # 将替换后的内容写回文件中
    with open(newfile_path, 'w',encoding='utf-8') as file:
        file.write(content)


def format_excel_data(input_file, format_data, end_marker):
    # 读取Excel表格内容
    usecols = ['CSR地址', 'CSR名称', 'CSR初始化']  
    df = pd.read_excel(input_file)
    columns = ['CSR地址', 'CSR名称','CSR初始化','CSR简介']
    df['CSR整数地址'] = df['CSR地址'].apply(lambda x: int(x, 16))
    new_format_data = format_data.copy()
    
    # CSR寄存器定义
    formatted_string = new_format_data[0] + '\n'
    for i in range(len(df)):
        formatted_data = df.loc[i, columns]
        formatted_string +=  ('    '*2 + 'reg [`REG_WIDTH-1:0] ' + "{:<20}".format(formatted_data['CSR名称']) + ' = ' 
                            + "{:<25}".format(formatted_data['CSR初始化']) +' ;' + "//? " + "{:<20}".format(formatted_data['CSR简介']) + '\n')
    new_format_data[0] = formatted_string + '    '*1 + end_marker[0]
    
    # CSR写定义
    formatted_string = new_format_data[1] + '\n'
    read_only_data = df.loc[df['CSR整数地址']<0xC00].copy()
    read_only_data = read_only_data.reset_index()
    for i in range(len(read_only_data)):
        formatted_data = read_only_data.loc[i, columns]
        formatted_string +=  ('    '*6 + '12\'h' + formatted_data['CSR地址'] + ' : ' + "{:<20}".format(formatted_data['CSR名称']) + ' <= ' 
                            + 'csr_data_i' +' ;' +'\n')
    new_format_data[1] = formatted_string + '    '*5 + end_marker[1]
    
    # CSR读定义
    formatted_string = new_format_data[2] + '\n'
    for i in range(len(df)):
        formatted_data = df.loc[i, columns]
        formatted_string +=  ('    '*4 + '12\'h' + formatted_data['CSR地址'] + ' : ' + 'csr_data_o' + ' <= ' 
                            + "{:<20}".format(formatted_data['CSR名称']) +' ;' +'\n')
    new_format_data[2] = formatted_string + '    '*3 + end_marker[2]
    
    # CSR寄存器硬件输出
    formatted_string = new_format_data[3] + '\n'
    output_data = df.loc[df['CSR寄存器硬件输出'] == 1].copy()
    output_data = output_data.reset_index()
    for i in range(len(output_data)):
        formatted_data = output_data.loc[i, columns]
        formatted_string +=  ('    '*1 + 'output      [`REG_WIDTH-1:0]      ' + formatted_data['CSR名称'] + '_o ' +',\n')
    new_format_data[3] = formatted_string + '    '*1 + end_marker[3]
    new_format_data[4] = new_format_data[4] + '\n' +'    '*1 + end_marker[3]
    return new_format_data
# 示例用法
input_file = file_path + 'CSR_list.xlsx'
oldfile_path  = file_path + 'CSR_regfile.v'
newfile_path  = file_path + 'CSR_regfile.v'
start_marker = ['//! CSR寄存器定义', '//! CSR写定义', '//! CSR读定义', '//! CSR寄存器硬件输出', '//! CSR异常处理']
end_marker   = ['//! CSR寄存器定义结束', '//! CSR写定义结束', '//! CSR读定义结束', '//! CSR寄存器硬件输出结束', '//! CSR异常处理结束']
formatted_data = format_excel_data(input_file, start_marker, end_marker)
new_field = formatted_data
replace_field_in_file(oldfile_path, start_marker, end_marker, newfile_path, new_field)
