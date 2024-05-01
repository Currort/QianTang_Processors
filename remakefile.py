import shutil

src_path = r"E:\Linux_share\Visiti_work\ppp\zynq_fsbl\zynq_fsbl_bsp\ps7_cortexa9_0\libsrc\gpio_v4_9\src\Makefile"
dst_path = r"E:\Linux_share\Visiti_work\ppp\hw\drivers\uart_test_v1_0\src\Makefile"
shutil.copy(src_path, dst_path)
dst_path = r"E:\Linux_share\Visiti_work\ppp\zynq_fsbl\zynq_fsbl_bsp\ps7_cortexa9_0\libsrc\uart_test_v1_0\src\Makefile"
shutil.copy(src_path, dst_path)
dst_path = r"E:\Linux_share\Visiti_work\ppp\ps7_cortexa9_0\standalone_domain\bsp\ps7_cortexa9_0\libsrc\uart_test_v1_0\src\Makefile"
shutil.copy(src_path, dst_path)


print('复制成功')
import torch
print("是否可用：", torch.cuda.is_available())        # 查看GPU是否可用
print("GPU数量：", torch.cuda.device_count())        # 查看GPU数量
print("torch方法查看CUDA版本：", torch.version.cuda)  # torch方法查看CUDA版本
print("GPU索引号：", torch.cuda.current_device())    # 查看GPU索引号
print("GPU名称：", torch.cuda.get_device_name())    # 根据索引号得到GPU名称