import os
import random
from pathlib import Path

def create_splits():
    # UAV123 annotations dir
    anno_dir = '/home/junjie/01_Research/SGLATrack-main/data/uav123/UAV123/anno/UAV123'
    if not os.path.exists(anno_dir):
        print(f"Directory not found: {anno_dir}")
        return
        
    # Get all sequence names (without .txt)
    sequences = sorted([f.replace('.txt', '') for f in os.listdir(anno_dir) if f.endswith('.txt')])
    print(f"Total sequences found: {len(sequences)}")
    
    # Use fixed seed for reproducibility
    random.seed(42)
    random.shuffle(sequences)
    
    # 60% train, 20% val, 20% test
    n_total = len(sequences)
    n_train = int(n_total * 0.6)
    n_val = int(n_total * 0.2)
    
    train_seqs = sequences[:n_train]
    val_seqs = sequences[n_train:n_train + n_val]
    test_seqs = sequences[n_train + n_val:]
    
    print(f"Train: {len(train_seqs)} | Val: {len(val_seqs)} | Test: {len(test_seqs)}")
    
    # Save to txt files
    base_dir = '/home/junjie/01_Research/SGLATrack-main/data/uav123/UAV123'
    with open(os.path.join(base_dir, 'train_split.txt'), 'w') as f:
        f.write('\n'.join(train_seqs))
    with open(os.path.join(base_dir, 'val_split.txt'), 'w') as f:
        f.write('\n'.join(val_seqs))
    with open(os.path.join(base_dir, 'test_split.txt'), 'w') as f:
        f.write('\n'.join(test_seqs))
        
    print(f"Splits saved to {base_dir}")

if __name__ == '__main__':
    create_splits()
