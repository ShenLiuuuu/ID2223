import re
import gradio as gr
from huggingface_hub import InferenceClient
from transformers import AutoTokenizer, TextStreamer
from unsloth import FastLanguageModel

model_name_or_path = "ZiLynn/lora_model"
max_seq_length = 2048

model, tokenizer = FastLanguageModel.from_pretrained(
    model_name=model_name_or_path,
    max_seq_length=max_seq_length,
    dtype=None,
    load_in_4bit=True,
)
FastLanguageModel.for_inference(model)

"""
For more information on `huggingface_hub` Inference API support, please check the docs: https://huggingface.co/docs/huggingface_hub/v0.22.2/en/guides/inference
"""


def respond(
    message,
    history: list[tuple[str, str]],
    system_message,
    max_tokens,
    temperature,
    top_p,
):
    
    messages = [{"role": "system", "content": system_message}]
    #for val in history:
     #   if val[0]:
      #      messages.append({"role": "user", "content": val[0]})
       # if val[1]:
        #    messages.append({"role": "assistant", "content": val[1]})
    messages.append({"role": "user", "content": message})
    text_streamer = TextStreamer(tokenizer, skip_prompt=True)
    inputs = tokenizer.apply_chat_template(
        messages,
        tokenize=True,
        add_generation_prompt=True,
        return_tensors="pt",
    ).to("cuda")
    responce = ""
    previous_response = ""
    
    for token in model.generate(
        input_ids=inputs,
        streamer=text_streamer,
        max_new_tokens=max_tokens,
        use_cache=True,
        temperature=temperature,
        top_p=top_p,
    ):
   
        responce = tokenizer.decode(token, skip_special_tokens=True)
        print("responce"+ responce)
    
    # 清理冗余标记
        responce = re.sub(
            r"(system.*?user\s*|assistant\s*)+",
            "",
            responce,
            flags=re.DOTALL,
        )
        print("decoded1:"+ responce)
        if message in responce:
            responce = responce.replace(message, "").strip()
        print("decoded2:"+ responce)
        yield responce.strip()


"""
For information on how to customize the ChatInterface, peruse the gradio docs: https://www.gradio.app/docs/chatinterface
"""
demo = gr.ChatInterface(
    respond,
    additional_inputs=[
        gr.Textbox(value="You are a friendly Chatbot.", label="System message"),
        gr.Slider(minimum=1, maximum=2048, value=512, step=1, label="Max new tokens"),
        gr.Slider(minimum=0.1, maximum=4.0, value=0.7, step=0.1, label="Temperature"),
        gr.Slider(
            minimum=0.1,
            maximum=1.0,
            value=0.95,
            step=0.05,
            label="Top-p (nucleus sampling)",
        ),
    ],
)


if __name__ == "__main__":
    demo.launch()
