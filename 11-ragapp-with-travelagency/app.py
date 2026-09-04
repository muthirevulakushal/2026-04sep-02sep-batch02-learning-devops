# --------------------- Import Essential Libraries ---------------------
import os
import streamlit as st

from dotenv import load_dotenv
from langchain_community.document_loaders import PyPDFDirectoryLoader
from langchain_text_splitters import CharacterTextSplitter
from langchain_core.vectorstores import InMemoryVectorStore
from langchain_openai import OpenAIEmbeddings, ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_classic.chains.combine_documents import create_stuff_documents_chain
from langchain_classic.chains import create_retrieval_chain


# --------------------- Page Configuration ---------------------
st.set_page_config(
    page_title="Bosch Smart AI Travel AI",
    layout="wide"
)

st.title("Bosch Smart AI Travel AI")
st.write("Ask questions about Bosch Smart AI Travel brochures.")


# --------------------- Load Environment Variables ---------------------
load_dotenv()

api_key = os.getenv("OPENAI_API_KEY")

if not api_key:
    st.error("OPENAI_API_KEY is not configured.")
    st.stop()


# --------------------- Load Documents & Create RAG Chain ---------------------
@st.cache_resource
def create_rag_chain():

    # --------------------- Document Loader ---------------------
    directory_path = "brochures/"

    loader = PyPDFDirectoryLoader(directory_path)
    docs = loader.load()

    if not docs:
        raise ValueError(
            "No PDF documents were found in the 'brochures/' directory."
        )

    # --------------------- Split Documents ---------------------
    text_splitter = CharacterTextSplitter(
        chunk_size=1000,
        chunk_overlap=0
    )

    documents = text_splitter.split_documents(docs)

    # --------------------- Embeddings ---------------------
    embeddings = OpenAIEmbeddings(
        model="text-embedding-3-small",
        api_key=api_key
    )

    # --------------------- Vector Store ---------------------
    vectorstore = InMemoryVectorStore.from_documents(
        documents,
        embedding=embeddings
    )

    # --------------------- Retriever ---------------------
    retriever = vectorstore.as_retriever()

    # --------------------- LLM ---------------------
    llm = ChatOpenAI(
        model="gpt-4o-mini",
        temperature=0,
        api_key=api_key
    )

    # --------------------- Prompt ---------------------
    prompt = ChatPromptTemplate.from_template("""
You are a Travel Agent for Bosch Smart AI Travel.

Answer ONLY using the context below.
If the answer is not in the context, say "I don't know".

Context:
{context}

Question: {input}

Answer:
""")

    # --------------------- Combine Documents Chain ---------------------
    combine_docs_chain = create_stuff_documents_chain(
        llm,
        prompt
    )

    # --------------------- Final RAG Chain ---------------------
    rag_chain = create_retrieval_chain(
        retriever,
        combine_docs_chain
    )

    return rag_chain


# --------------------- Initialize RAG ---------------------
try:
    rag_chain = create_rag_chain()

except Exception as e:
    st.error(f"Error initializing the RAG application: {e}")
    st.stop()


# --------------------- Chat History ---------------------
if "messages" not in st.session_state:
    st.session_state.messages = []


# --------------------- Display Previous Messages ---------------------
for message in st.session_state.messages:

    with st.chat_message(message["role"]):
        st.markdown(message["content"])


# --------------------- User Query ---------------------
query = st.chat_input(
    "Ask a question about Bosch Smart AI Travel..."
)


if query:

    # Display user message
    st.session_state.messages.append({
        "role": "user",
        "content": query
    })

    with st.chat_message("user"):
        st.markdown(query)

    # Generate response
    with st.chat_message("assistant"):

        with st.spinner("Searching Bosch Smart AI Travel brochures..."):

            try:
                response = rag_chain.invoke({
                    "input": query
                })

                answer = response["answer"]

                st.markdown(answer)

                # --------------------- Sources ---------------------
                sources = []

                for doc in response.get("context", []):

                    source = doc.metadata.get("source")

                    if source and source not in sources:
                        sources.append(source)

                if sources:

                    with st.expander("Sources"):

                        for source in sources:
                            st.write(f"- {source}")

                # Save assistant response
                st.session_state.messages.append({
                    "role": "assistant",
                    "content": answer
                })

            except Exception as e:

                error_message = f"An error occurred: {e}"

                st.error(error_message)

                st.session_state.messages.append({
                    "role": "assistant",
                    "content": error_message
                })


# --------------------- Sidebar ---------------------
with st.sidebar:

    st.header(" Bosch Smart AI Travel")

    st.write(
        "This application uses Retrieval-Augmented Generation (RAG) "
        "to answer questions from the travel brochures."
    )

    st.divider()

    if st.button("Clear Chat"):

        st.session_state.messages = []

        st.rerun()

    st.divider()

    st.caption("Powered by OpenAI + LangChain + Streamlit")
