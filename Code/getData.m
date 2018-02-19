function Accuracy = getData(label, yTest, name)

truePos = 0;
trueNeg = 0;
falsePos = 0;
falseNeg = 0;

for index = 1:size(label,1)
    %disp(yTest(index));
    %disp(label(index));
    
    if (yTest(index) == '1')
       if (yTest(index) == label(index))
           %fprintf('tp\n');
           truePos = truePos + 1;
       else
           %fprintf('fn\n');
           falseNeg = falseNeg + 1;
       end 
    end
    if (yTest(index) == '2')
       if (yTest(index) == label(index))
           %fprintf('tn\n');
           trueNeg = trueNeg + 1;
       else
           %fprintf('fp\n');
           falsePos = falsePos + 1;
       end    
    end
end

Accuracy = (truePos + trueNeg) / size(label,1);
TPR = truePos / (truePos + falseNeg);
Precision = truePos / (truePos + falsePos);
FPR = falsePos / (falsePos + trueNeg);

fprintf('\n');

fprintf('Stats for %s\n\n',name);

fprintf('True Positive: %f\n', truePos);
fprintf('False Positive: %f\n', falsePos);
fprintf('True Negative: %f\n', trueNeg);
fprintf('False Negative: %f\n', falseNeg);

fprintf('\n');

fprintf('Accuracy: %f\n', Accuracy*100);
fprintf('True Positive Rate: %f\n', TPR*100);
fprintf('Precision: %f\n', Precision*100);
fprintf('False Positive Rate: %f\n', FPR*100);

