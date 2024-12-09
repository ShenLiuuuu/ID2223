### To improve model performance

# (a) model-centric approach
1. Adjust the rank of LoRA layers (start with a low rank and adjust gradually)
2. Apply LoRA only to certain layers of the model, because not all layers are equally important
3. Combine Adapter Layers and LoRA together (maybe insert LoRA to some specific layers and adapters to others), it can make the model more scalable
4. Use more advanced learning rate scheduler and optimizer  


# (b) data-centric approach
1. Augment the dataset
2. Balance the dataset to make the model generalizes better
