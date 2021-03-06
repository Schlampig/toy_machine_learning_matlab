function [vec_res] = EkNN_test(train_all_new,test_all,k)


[r_test,~] = size(test_all);
train_label = train_all_new(:,end-1)+1;%多数类label是1，少数类是2，+1是防止后期排序的hist出现NaN值
test_label = test_all(:,end)+1;%多数类label是1，少数类是2 
r_classone = length(find(test_label(:)==1));%统计测试数据label属于多数类的个数（label==1）
r_classtwo = r_test - r_classone;%统计测试数据label属于少数类的个数（label==2）
vec_acc_1 = zeros(r_classone,1);%行是测试样本数，列是第1类(多数类Negative)
vec_acc_2 = zeros(r_classtwo,1);%行是测试样本数，列是第2类（少数类Positive）
count_1 = 1;%初始化计数
count_2 = 1;


for i_test = 1:r_test
    
    temp = repmat(test_all(i_test,1:end-1),size(train_all_new,1),1) - train_all_new(:,1:end-2);
    vec_temp = sqrt(sum(temp.^2,2)) - train_all_new(:,end);
    
    [~,index1] = sort(vec_temp);
    [~,index2] = sort(index1);%给距离排序
    vec_candidate = (train_label(find(index2<=k)))';%候选类向量，或一个数；转置为行向量是因为hist处理列向量时label和rank行列表示会变动
    if k ~=1%用于k近邻统计每一类近邻个数
        [j_rank,j_label] = hist(vec_candidate, unique(vec_candidate));%统计出现最多的值
        y = [j_label',j_rank']; 
        z = sortrows(y,-2);%按照出现次数多少来排序，次数少的沉底，降序加负号,把投票数最多的判定为当前分块所属于的类
    else
        z(1,1) = vec_candidate;%最近邻不必求离散分布并投票
    end%if
    
    if z(1,1) == test_label(i_test); 
        answer = 1;
    else
        answer = 0;
    end%if
    
    if test_label(i_test) == 1;
        vec_acc_1(count_1) = answer;
        count_1 = count_1 + 1;
    else
        vec_acc_2(count_2) = answer;
        count_2 = count_2 + 1;
    end%if
    
    clear j_rank;clear j_label;clear vec_candidate;
    clear index1;clear index2;
end%for_i_test


TP = length(find(vec_acc_2(:)==1));%少数类（Positive）里面分对的个数
TN = length(find(vec_acc_1(:)==1));%多数类（Negative）里面分对的个数
FN = r_classtwo - TP;%少数类（Positive）里面分错的个数
FP = r_classone - TN;%多数类（Negative）里面分错的个数

TP_rate = TP/(TP+FN);
FP_rate = FP/(FP+TN);
TN_rate = TN/(FP+TN);
FN_rate = FN/(TP+FN);
Acc = (TP+TN)/(TP+TN+FP+FN)*100;%总分类精确度
Acc2 = (TP_rate+TN_rate)*50;%算术平均
GM = sqrt((TP/(TP+FN))*(TN/(TN+FP)))*100;%几何平均
AUC = (1+TP_rate-FP_rate)*50;%AUC

vec_res = [TP,FP,TN,FN,Acc,Acc2,GM,AUC];

end